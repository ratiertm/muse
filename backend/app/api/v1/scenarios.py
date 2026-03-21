"""Scenario CRUD endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.scenario import (
    ScenarioCreate,
    ScenarioUpdate,
    ScenarioResponse,
    WorldStateUpdate,
    ScenarioCharacterAdd,
    CharacterInScenarioResponse,
    ScenarioAutoGenerateRequest,
)
from app.schemas.character import CharacterResponse
from app.schemas.common import PaginationParams, PaginatedResponse
from app.services.scenario_service import ScenarioService
from app.core.llm_client import llm_client
from app.core.auth import get_current_user
from app.models.user import User

import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("", response_model=ScenarioResponse, status_code=201)
async def create_scenario(
    scenario_data: ScenarioCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new scenario"""
    scenario = await ScenarioService.create_scenario(
        db=db,
        user_id=current_user.id,
        scenario_data=scenario_data,
    )
    return scenario


@router.post("/auto-generate", response_model=ScenarioResponse, status_code=201)
async def auto_generate_scenario(
    request: ScenarioAutoGenerateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Auto-generate a scenario + characters from a source work using AI"""
    from app.schemas.character import CharacterCreate
    from app.services.character_service import CharacterService

    def parse_json(text: str) -> dict:
        text = text.strip()
        if text.startswith("```"):
            text = text.split("\n", 1)[1].rsplit("```", 1)[0].strip()
        return json.loads(text)

    try:
        # === Step 1: Generate scenario ===
        scenario_prompt = f"""Generate a roleplay scenario based on "{request.source_work}".
Return JSON: {{"name": "제목", "description": "설명 2-3문단", "world_state": {{"timeline": "...", "location": "...", "current_time": "...", "world_facts": ["..."]}}}}
Korean only. JSON only."""

        scenario_response = await llm_client.complete(
            messages=[{"role": "user", "content": scenario_prompt}],
            model="gpt-4o-mini", temperature=0.7, max_tokens=1500,
        )
        scenario_data_raw = parse_json(scenario_response)

        scenario = await ScenarioService.create_scenario(
            db=db, user_id=current_user.id,
            scenario_data=ScenarioCreate(
                name=scenario_data_raw.get("name", request.source_work),
                description=scenario_data_raw.get("description", ""),
                world_state=scenario_data_raw.get("world_state", {}),
            ),
        )
        logger.info(f"Created scenario: {scenario.name}")

        # === Step 2: Generate characters (separate call) ===
        char_prompt = f"""Generate 3-4 main characters from "{request.source_work}" for roleplay.
Return JSON array: [{{"name":"이름","personality":"성격 2문장","speech_style":"말투 1문장","backstory":"배경 2문장","first_message":"첫인사 1문장","tags":["태그"],"avatar_url":"https://cdn.myanimelist.net/images/characters/XX/XXXXX.jpg"}}]
For avatar_url, provide a real MyAnimeList character image URL if you know it. If unsure, set null.
Korean only. JSON array only."""

        char_response = await llm_client.complete(
            messages=[{"role": "user", "content": char_prompt}],
            model="gpt-4o-mini", temperature=0.7, max_tokens=2000,
        )

        logger.info(f"Character LLM response length: {len(char_response)}")
        logger.debug(f"Character LLM response: {char_response[:500]}")

        char_text = char_response.strip()
        if char_text.startswith("```"):
            char_text = char_text.split("\n", 1)[1].rsplit("```", 1)[0].strip()

        # Try to find JSON array in response
        if not char_text.startswith("[") and not char_text.startswith("{"):
            # Look for [ or { in the text
            arr_start = char_text.find("[")
            obj_start = char_text.find("{")
            if arr_start >= 0:
                char_text = char_text[arr_start:]
            elif obj_start >= 0:
                char_text = char_text[obj_start:]

        # Handle both array and object with characters key
        char_parsed = json.loads(char_text)
        if isinstance(char_parsed, dict):
            characters_list = char_parsed.get("characters", [])
        else:
            characters_list = char_parsed

        # Helper: fetch character image from Jikan API (MAL)
        import httpx

        async def fetch_avatar(name: str) -> str | None:
            try:
                async with httpx.AsyncClient(timeout=10) as client:
                    resp = await client.get(
                        "https://api.jikan.moe/v4/characters",
                        params={"q": name, "limit": 1},
                    )
                    if resp.status_code == 200:
                        data = resp.json()
                        items = data.get("data", [])
                        if items:
                            return items[0].get("images", {}).get("jpg", {}).get("image_url")
            except Exception:
                pass
            return None

        created_count = 0
        for char_data in characters_list:
            try:
                for field in ['personality', 'speech_style', 'backstory', 'first_message']:
                    if field in char_data and isinstance(char_data[field], list):
                        char_data[field] = "\n".join(str(item) for item in char_data[field])

                tags = char_data.get("tags", [])
                if isinstance(tags, str):
                    tags = [tags]

                # Fetch avatar from MAL via Jikan API
                avatar = char_data.get("avatar_url")
                if not avatar or not avatar.startswith("http"):
                    avatar = await fetch_avatar(char_data.get("name", ""))
                    import asyncio
                    await asyncio.sleep(0.5)  # Jikan rate limit

                character = await CharacterService.create_character(
                    db=db, user_id=current_user.id,
                    character_data=CharacterCreate(
                        name=char_data.get("name", "Unknown"),
                        personality=char_data.get("personality", ""),
                        speech_style=char_data.get("speech_style", ""),
                        backstory=char_data.get("backstory", ""),
                        first_message=char_data.get("first_message", ""),
                        tags=tags,
                        avatar_url=avatar,
                    ),
                )
                await ScenarioService.add_character_to_scenario(
                    db=db, scenario_id=scenario.id, character_id=character.id,
                    user_id=current_user.id,
                )
                created_count += 1
            except Exception as ce:
                logger.warning(f"Failed to create character {char_data.get('name')}: {ce}")

        logger.info(f"Auto-generated scenario '{scenario.name}' with {created_count} characters")
        return scenario

    except json.JSONDecodeError as je:
        logger.error(f"JSON parse failed for characters: {je}. Raw: {char_text[:300] if 'char_text' in dir() else 'N/A'}")
        # 시나리오는 이미 생성됨 — 캐릭터만 실패한 경우 시나리오는 반환
        if 'scenario' in dir():
            return scenario
        raise HTTPException(status_code=400, detail=f"시나리오 자동 생성 실패: {str(je)}")
    except Exception as e:
        logger.error(f"Scenario auto-generation failed: {e}")
        if 'scenario' in dir():
            return scenario
        raise HTTPException(status_code=400, detail=f"시나리오 자동 생성 실패: {str(e)}")


@router.get("", response_model=PaginatedResponse[ScenarioResponse])
async def list_scenarios(
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=10, ge=1, le=100, description="Items per page"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get scenario list with pagination
    
    - **page**: Page number (1-indexed)
    - **per_page**: Number of items per page (max 100)
    """
    pagination = PaginationParams(page=page, per_page=per_page)
    
    scenarios, total = await ScenarioService.get_scenarios(
        db=db,
        user_id=current_user.id,
        offset=pagination.offset,
        limit=pagination.per_page,
    )

    # Add is_mine flag + character avatars
    items = []
    for s in scenarios:
        resp = ScenarioResponse.model_validate(s)
        resp.is_mine = (s.user_id == current_user.id)
        # Fetch character avatars for this scenario
        characters = await ScenarioService.get_scenario_characters(
            db=db, scenario_id=s.id, user_id=current_user.id,
        )
        resp.character_avatars = [
            {"id": str(c.id), "name": c.name, "avatar_url": c.avatar_url}
            for c in characters
        ]
        items.append(resp)

    return PaginatedResponse.create(
        items=items,
        total=total,
        page=pagination.page,
        per_page=pagination.per_page,
    )


@router.get("/{scenario_id}", response_model=ScenarioResponse)
async def get_scenario(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific scenario by ID"""
    scenario = await ScenarioService.get_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.put("/{scenario_id}", response_model=ScenarioResponse)
async def update_scenario(
    scenario_id: UUID,
    scenario_data: ScenarioUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a scenario"""
    scenario = await ScenarioService.update_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
        scenario_data=scenario_data,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.patch("/{scenario_id}/world-state", response_model=ScenarioResponse)
async def update_world_state(
    scenario_id: UUID,
    world_state_data: WorldStateUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update world_state with partial updates (merge)"""
    scenario = await ScenarioService.update_world_state(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
        world_state_data=world_state_data,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.delete("/{scenario_id}", status_code=204)
async def delete_scenario(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a scenario"""
    deleted = await ScenarioService.delete_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    if not deleted:
        raise HTTPException(status_code=404, detail="Scenario not found")


# Character management endpoints

@router.post("/{scenario_id}/characters", status_code=201)
async def add_character_to_scenario(
    scenario_id: UUID,
    character_data: ScenarioCharacterAdd,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Add a character to a scenario"""
    added = await ScenarioService.add_character_to_scenario(
        db=db,
        scenario_id=scenario_id,
        character_id=character_data.character_id,
        user_id=current_user.id,
    )
    
    if not added:
        raise HTTPException(
            status_code=400,
            detail="Failed to add character (not found or already exists)",
        )
    
    return {"message": "Character added to scenario successfully"}


@router.get("/{scenario_id}/characters", response_model=list[CharacterResponse])
async def get_scenario_characters(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all characters in a scenario"""
    characters = await ScenarioService.get_scenario_characters(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    return characters


@router.delete("/{scenario_id}/characters/{character_id}", status_code=204)
async def remove_character_from_scenario(
    scenario_id: UUID,
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Remove a character from a scenario"""
    removed = await ScenarioService.remove_character_from_scenario(
        db=db,
        scenario_id=scenario_id,
        character_id=character_id,
        user_id=current_user.id,
    )
    
    if not removed:
        raise HTTPException(status_code=404, detail="Character not found in scenario")
