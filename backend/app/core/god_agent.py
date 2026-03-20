"""God Agent for omniscient scenario orchestration"""
import json
import logging
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.llm_client import LLMClient
from app.core.god_prompts import (
    BRIEFING_SYSTEM_PROMPT,
    BRIEFING_TEMPLATE,
    UPDATE_SYSTEM_PROMPT,
    EVENT_EXTRACTION_TEMPLATE,
)
from app.models.character import Character
from app.models.scenario import Scenario
from app.services.knowledge_service import KnowledgeService
from app.services.private_state_service import PrivateStateService
from app.services.scenario_service import ScenarioService

logger = logging.getLogger(__name__)


class GodAgent:
    """
    Omniscient orchestrator that maintains world state and generates character briefings.
    Uses GPT-4o-mini for fast, structured reasoning.
    """
    
    def __init__(self, llm_client: LLMClient, model: str = "gpt-4o-mini"):
        """
        Initialize God Agent
        
        Args:
            llm_client: LLM client for API calls
            model: Model to use (default: gpt-4o-mini for speed and cost)
        """
        self.llm_client = llm_client
        self.model = model
    
    async def brief_character(
        self,
        db: AsyncSession,
        character: Character,
        scenario: Scenario,
        user_message: str,
        conversation_history: list[dict[str, str]] | None = None,
    ) -> str:
        """
        Generate a contextual briefing for a character before they respond.
        
        The briefing tells the character:
        - What they know (and don't know)
        - Current world state and recent events
        - Their emotional state and feelings
        - Relevant context for the current situation
        
        Args:
            db: Database session
            character: Character to brief
            scenario: Current scenario
            user_message: The message the character is responding to
            conversation_history: Recent conversation context
        
        Returns:
            Briefing text to prepend to character's system prompt
        """
        # Load character's knowledge
        knowledge = await KnowledgeService.get_or_create_knowledge(
            db, character.id, scenario.id
        )
        
        # Load character's private state
        private_state = await PrivateStateService.get_or_create_state(
            db, character.id, scenario.id
        )
        
        # Format world state
        world_state_text = self._format_world_state(scenario.world_state)
        
        # Format known facts
        known_facts_text = "\n".join(f"- {fact}" for fact in knowledge.known_facts) if knowledge.known_facts else "(None yet)"
        
        # Format unknown facts (for God Agent awareness only)
        unknown_facts_text = "\n".join(f"- {fact}" for fact in knowledge.unknown_facts) if knowledge.unknown_facts else "(None)"
        
        # Format feelings
        feelings_text = "\n".join(
            f"- {target}: {sentiment}"
            for target, sentiment in private_state.feelings_toward.items()
        ) if private_state.feelings_toward else "(No specific feelings recorded)"
        
        # Format secrets
        secrets_text = "\n".join(f"- {secret}" for secret in private_state.secrets) if private_state.secrets else "(None)"
        
        # Format conversation context
        conversation_context = ""
        if conversation_history:
            recent = conversation_history[-3:]  # Last 3 exchanges
            conversation_context = "Recent conversation:\n" + "\n".join(
                f"{msg['role']}: {msg['content']}" for msg in recent
            )
        
        # Build briefing prompt
        prompt = BRIEFING_TEMPLATE.format(
            character_name=character.name,
            world_state=world_state_text,
            known_facts=known_facts_text,
            unknown_facts=unknown_facts_text,
            inner_thoughts=private_state.inner_thoughts or "(No specific thoughts yet)",
            feelings_toward=feelings_text,
            secrets=secrets_text,
            user_message=user_message,
            conversation_context=conversation_context,
        )
        
        # Call LLM to generate briefing
        messages = [
            {"role": "system", "content": BRIEFING_SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ]
        
        try:
            briefing = await self.llm_client.complete(
                messages=messages,
                model=self.model,
                temperature=0.3,  # Low temperature for consistency
                max_tokens=500,
            )
            
            logger.info(f"Generated briefing for {character.name} in scenario {scenario.id}")
            return briefing
        
        except Exception as e:
            logger.error(f"Failed to generate briefing: {e}")
            # Return minimal briefing on error
            return f"You are {character.name}. The user just said: {user_message}"
    
    async def observe_and_update(
        self,
        db: AsyncSession,
        character: Character,
        scenario: Scenario,
        user_message: str,
        assistant_response: str,
    ) -> dict:
        """
        Observe a conversation exchange and extract updates to world state and character state.
        
        Extracts:
        - New events to add to world_state
        - New facts the character learned
        - Emotional changes toward other characters
        - New secrets the character gained
        - Updated inner thoughts
        
        Args:
            db: Database session
            character: Character who responded
            scenario: Current scenario
            user_message: User's message
            assistant_response: Character's response
        
        Returns:
            Dict with extracted updates (for logging/debugging)
        """
        # Format current world state
        world_state_text = self._format_world_state(scenario.world_state)
        
        # Build extraction prompt
        prompt = EVENT_EXTRACTION_TEMPLATE.format(
            character_name=character.name,
            world_state=world_state_text,
            user_message=user_message,
            assistant_response=assistant_response,
        )
        
        # Call LLM to extract events and updates
        messages = [
            {"role": "system", "content": UPDATE_SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ]
        
        try:
            response = await self.llm_client.complete(
                messages=messages,
                model=self.model,
                temperature=0.2,  # Very low temperature for structured output
                max_tokens=800,
            )
            
            # Parse JSON response with fallback
            updates = self._parse_json_response(response)
            
            # Apply updates to database
            await self._apply_updates(db, character, scenario, updates)
            
            logger.info(f"Applied updates from {character.name}'s conversation: {updates}")
            return updates
        
        except Exception as e:
            logger.error(f"Failed to extract/apply updates: {e}")
            return {
                "new_events": [],
                "new_known_facts": [],
                "emotion_changes": {},
                "new_secrets": [],
                "inner_thoughts_update": "",
            }
    
    def _format_world_state(self, world_state: dict | None) -> str:
        """Format world_state dict into readable text"""
        if not world_state:
            return "No world state established yet."
        
        parts = []
        
        if "timeline" in world_state:
            parts.append(f"Timeline: {world_state['timeline']}")
        
        if "location" in world_state:
            parts.append(f"Location: {world_state['location']}")
        
        if "current_time" in world_state:
            parts.append(f"Current time: {world_state['current_time']}")
        
        if "active_events" in world_state and world_state["active_events"]:
            events = "\n".join(f"- {event}" for event in world_state["active_events"])
            parts.append(f"Active events:\n{events}")
        
        if "world_facts" in world_state and world_state["world_facts"]:
            facts = "\n".join(f"- {fact}" for fact in world_state["world_facts"])
            parts.append(f"World facts:\n{facts}")
        
        return "\n\n".join(parts) if parts else "No world state details."
    
    def _parse_json_response(self, response: str) -> dict:
        """
        Parse JSON response from LLM with fallback handling.
        
        Args:
            response: LLM response (should be JSON)
        
        Returns:
            Parsed dict or empty structure on failure
        """
        # Try to extract JSON from markdown code block if present
        response = response.strip()
        
        if "```json" in response:
            start = response.find("```json") + 7
            end = response.find("```", start)
            if end != -1:
                response = response[start:end].strip()
        elif "```" in response:
            start = response.find("```") + 3
            end = response.find("```", start)
            if end != -1:
                response = response[start:end].strip()
        
        try:
            parsed = json.loads(response)
            
            # Validate structure
            return {
                "new_events": parsed.get("new_events", []),
                "new_known_facts": parsed.get("new_known_facts", []),
                "emotion_changes": parsed.get("emotion_changes", {}),
                "new_secrets": parsed.get("new_secrets", []),
                "inner_thoughts_update": parsed.get("inner_thoughts_update", ""),
            }
        
        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse JSON response: {e}\nResponse: {response}")
            return {
                "new_events": [],
                "new_known_facts": [],
                "emotion_changes": {},
                "new_secrets": [],
                "inner_thoughts_update": "",
            }
    
    async def _apply_updates(
        self,
        db: AsyncSession,
        character: Character,
        scenario: Scenario,
        updates: dict,
    ) -> None:
        """
        Apply extracted updates to database.
        
        Args:
            db: Database session
            character: Character being updated
            scenario: Current scenario
            updates: Parsed updates dict
        """
        # Update world state (new events and facts)
        if updates["new_events"]:
            current_state = scenario.world_state or {}
            active_events = current_state.get("active_events", [])
            
            for event in updates["new_events"]:
                if event not in active_events:
                    active_events.append(event)
            
            current_state["active_events"] = active_events
            scenario.world_state = current_state
            await db.flush()  # Flush to update scenario
        
        # Update character knowledge
        for fact in updates["new_known_facts"]:
            await KnowledgeService.add_known_fact(
                db, character.id, scenario.id, fact
            )
        
        # Update emotional states
        for target, sentiment in updates["emotion_changes"].items():
            await PrivateStateService.update_feeling(
                db, character.id, scenario.id, target, sentiment
            )
        
        # Add new secrets
        for secret in updates["new_secrets"]:
            await PrivateStateService.add_secret(
                db, character.id, scenario.id, secret
            )
        
        # Update inner thoughts
        if updates["inner_thoughts_update"]:
            await PrivateStateService.update_inner_thoughts(
                db, character.id, scenario.id, updates["inner_thoughts_update"]
            )
        
        # Commit all changes
        await db.commit()
