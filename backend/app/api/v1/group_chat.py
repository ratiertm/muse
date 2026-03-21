"""Group chat endpoints with God Agent orchestration"""
import asyncio
import json
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.chat import (
    GroupChatCreateRequest,
    GroupChatMessageRequest,
    GroupChatStreamEvent,
    ConversationResponse,
)
from app.schemas.character import CharacterResponse
from app.services.chat_service import ChatService
from app.services.character_service import CharacterService
from app.services.scenario_service import ScenarioService
from app.core.llm_client import llm_client
from app.core.prompt_builder import PromptBuilder
from app.core.context_manager import ContextManager
from app.core.god_agent import GodAgent
from app.core.auth import get_current_user
from app.models.user import User
from app.models.message import MessageRole
from app.services.persona_service import PersonaService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("", response_model=ConversationResponse)
async def create_group_chat(
    request: GroupChatCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a new group conversation
    
    Creates a group chat with multiple characters in a scenario.
    Requires at least 2 characters and a valid scenario.
    
    Args:
        scenario_id: Scenario ID for God Agent orchestration
        character_ids: List of character IDs (minimum 2)
        title: Group chat title
    
    Returns:
        Created conversation
    """
    # Verify scenario is accessible (own or public)
    scenario = await ScenarioService.get_scenario(db, request.scenario_id, current_user.id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    # Verify all characters exist and belong to user
    for char_id in request.character_ids:
        character = await CharacterService.get_character(
            db=db,
            character_id=char_id,
            user_id=current_user.id,
        )
        if not character:
            raise HTTPException(
                status_code=404,
                detail=f"Character {char_id} not found"
            )
    
    # Create group conversation
    conversation = await ChatService.create_group_conversation(
        db=db,
        user_id=current_user.id,
        scenario_id=request.scenario_id,
        character_ids=request.character_ids,
        title=request.title,
        persona_id=request.persona_id,
    )
    
    logger.info(f"Created group conversation {conversation.id} with {len(request.character_ids)} characters")
    
    return conversation


@router.get("/{conversation_id}/participants", response_model=list[CharacterResponse])
async def get_group_participants(
    conversation_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get all participants in a group conversation
    
    Args:
        conversation_id: Group conversation ID
    
    Returns:
        List of characters in the group
    """
    # Verify conversation exists and belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Not a group conversation")
    
    # Get participants
    participants = await ChatService.get_group_participants(db, conversation_id)
    
    return participants


@router.post("/{conversation_id}/message")
async def send_group_message(
    conversation_id: UUID,
    request: GroupChatMessageRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Send a message in a group chat and get streamed responses from multiple characters
    
    Flow:
    1. God Agent decides which character(s) should respond
    2. For each responding character:
       - God Agent generates briefing (with knowledge filtering)
       - Character Agent generates response (streamed)
       - Response is saved with character_id
       - God Agent updates world state (background)
    3. All responses are streamed as SSE events
    
    Args:
        conversation_id: Group conversation ID
        message: User message text
    
    Returns:
        SSE stream with character responses
        Event format: {"character_id": "...", "character_name": "...", "chunk": "...", "is_done": false}
        Final event: {"is_done": true}
    """
    # Verify conversation exists and belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Not a group conversation")
    
    if not conversation.scenario_id:
        raise HTTPException(status_code=400, detail="Group chat requires a scenario")
    
    # Get scenario
    scenario = await ScenarioService.get_scenario(db, conversation.scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    # Get all participants
    participants = await ChatService.get_group_participants(db, conversation_id)
    
    if not participants:
        raise HTTPException(status_code=400, detail="No participants in group chat")
    
    # Save user message
    await ChatService.save_group_message(
        db=db,
        conversation_id=conversation_id,
        role=MessageRole.USER,
        content=request.message,
        character_id=None,  # User message
    )
    
    # Get recent conversation history
    history_messages = await ChatService.get_recent_messages(
        db=db,
        conversation_id=conversation_id,
        limit=30,
    )
    
    # Convert to dict format for God Agent
    conversation_history = [
        {"role": msg.role.value, "content": msg.content}
        for msg in history_messages
    ]
    
    # Load persona if set
    persona = None
    if conversation.persona_id:
        persona = await PersonaService.get_persona(
            db=db,
            persona_id=conversation.persona_id,
            user_id=current_user.id,
        )

    user_name = persona.name if persona else "User"

    # === FAST GROUP CHAT: Single LLM call with full context ===

    # Full character profiles
    characters_info = "\n\n".join([
        f"### {char.name}\n"
        f"- 성격: {char.personality}\n"
        f"- 말투: {char.speech_style}\n"
        f"- 배경: {char.backstory[:200] if char.backstory else '없음'}"
        for char in participants
    ])

    # User persona
    persona_info = ""
    if persona:
        persona_info = f"""## 유저 페르소나: {persona.name}
- 외모: {persona.appearance or '미설정'}
- 성격: {persona.personality or '미설정'}
- 설명: {persona.description or '미설정'}
"""

    # World state
    world_state = scenario.world_state or {}
    world_info = ""
    if world_state:
        world_info = f"""## 세계 상태
- 시간축: {world_state.get('timeline', '미설정')}
- 장소: {world_state.get('location', '미설정')}
- 현재 시점: {world_state.get('current_time', '미설정')}
"""
        facts = world_state.get('world_facts', [])
        if facts:
            world_info += "- 주요 사실:\n" + "\n".join(f"  · {f}" for f in facts[:5])

    # Conversation context with character names
    char_id_to_name = {str(c.id): c.name for c in participants}
    recent_history = "\n".join([
        f"[{user_name}]: {msg.content[:200]}" if msg.role.value == 'user'
        else f"[{char_id_to_name.get(str(msg.character_id), '?')}]: {msg.content[:200]}"
        for msg in history_messages[-10:]
    ])

    combined_prompt = f"""You are a God Agent — an omniscient narrator orchestrating a group roleplay.

## 시나리오: {scenario.name}
{scenario.description[:500] if scenario.description else ''}

{world_info}

{persona_info}

## 참여 캐릭터:
{characters_info}

## 최근 대화:
{recent_history}

## 유저({user_name})의 메시지:
"{request.message}"

---

## 지시사항 (God Agent로서):
1. 각 캐릭터가 원작 애니/만화/소설에서 말하는 것처럼 대사를 작성할 것
   - 성격이 나쁘면 나쁘게, 거칠면 거칠게, 겁쟁이면 겁먹은 듯이
   - 캐릭터 고유의 말버릇, 구두점, 감탄사를 반드시 사용
   - 캐릭터의 감정과 태도가 대사에 드러나야 함
2. 유저({user_name})를 페르소나 이름으로 부를 것
3. 세계 상태와 시나리오 배경에 맞게 상황을 조율
4. 모든 캐릭터가 반응할 필요 없음 — 상황에 맞는 캐릭터만 대답 (최소 1명)
5. 각 캐릭터는 1인칭으로, 1-3문장 짧게 말할 것
6. 시작에 [상황 나레이션]을 한 줄 넣을 것
7. 한국어로 작성

## 출력 형식:
[상황 나레이션]

**캐릭터이름**: 대사

**캐릭터이름**: 대사"""

    async def event_generator():
        """Single LLM call, then parse and send per-character events"""
        import re

        # Collect full response first
        full_response = ""
        try:
            async for chunk in llm_client.stream(
                messages=[{"role": "user", "content": combined_prompt}],
                model="claude-sonnet-4-20250514",
                temperature=0.7,
                max_tokens=1000,
            ):
                full_response += chunk

            # Clean bkit artifacts
            for marker in ["─────", "📊 bkit", "✅ Used:", "⏭️ Not Used:"]:
                idx = full_response.find(marker)
                if idx > 0:
                    full_response = full_response[:idx].rstrip()

            # Extract [narration] — send as system message
            narration_match = re.search(r'\[([^\]]+)\]', full_response)
            if narration_match:
                narration = narration_match.group(0)
                narration_event = GroupChatStreamEvent(
                    character_id=None,
                    character_name="narrator",
                    chunk=narration,
                    is_done=False,
                )
                yield f"data: {narration_event.model_dump_json()}\n\n"

            # Parse per-character responses: **이름**: 대사
            char_map = {char.name: char for char in participants}
            pattern = r'\*\*(.+?)\*\*:\s*(.+?)(?=\n\*\*|\n\n\*\*|$)'
            matches = re.findall(pattern, full_response, re.DOTALL)

            for char_name, dialogue in matches:
                char_name = char_name.strip()
                dialogue = dialogue.strip()

                if not dialogue:
                    continue

                # Find matching character
                char = char_map.get(char_name)
                if not char:
                    # Fuzzy match
                    for name, c in char_map.items():
                        if name in char_name or char_name in name:
                            char = c
                            break

                if char:
                    # Send header
                    header = GroupChatStreamEvent(
                        character_id=char.id,
                        character_name=char.name,
                        chunk="",
                        is_done=False,
                    )
                    yield f"data: {header.model_dump_json()}\n\n"

                    # Send dialogue
                    msg_event = GroupChatStreamEvent(
                        character_id=char.id,
                        character_name=char.name,
                        chunk=dialogue,
                        is_done=False,
                    )
                    yield f"data: {msg_event.model_dump_json()}\n\n"

                    # Save to DB
                    await ChatService.save_group_message(
                        db=db,
                        conversation_id=conversation_id,
                        role=MessageRole.ASSISTANT,
                        content=dialogue,
                        character_id=char.id,
                    )

            yield "data: " + GroupChatStreamEvent(is_done=True).model_dump_json() + "\n\n"

        except Exception as e:
            logger.error(f"Group chat error: {e}")
            error_event = GroupChatStreamEvent(
                chunk=f"\n\n[응답 생성 중 오류가 발생했습니다]",
                is_done=False,
            )
            yield f"data: {error_event.model_dump_json()}\n\n"
            yield "data: " + GroupChatStreamEvent(is_done=True).model_dump_json() + "\n\n"
    
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
            "X-Conversation-Id": str(conversation_id),
        },
    )
