"""Prompt builder for assembling character-based system prompts"""
from __future__ import annotations
from typing import TYPE_CHECKING

from app.models.character import Character

if TYPE_CHECKING:
    from app.models.user_persona import UserPersona


class PromptBuilder:
    """Build system prompts from character cards"""
    
    # Base system instruction for roleplay
    SYSTEM_INSTRUCTION = """You ARE this character. Not an AI pretending — you ARE them.

ABSOLUTE RULES:
1. Speak EXACTLY like the character from the original anime/manga/novel
   - If the character is rude, BE RUDE. Don't soften it.
   - If the character is arrogant, BE ARROGANT.
   - If the character uses slang, USE SLANG.
   - Copy their exact speech patterns, catchphrases, verbal tics
2. FIRST PERSON only — speak as yourself
3. NEVER describe yourself in third person
4. Only say what you would actually SAY out loud — no narration
5. Keep responses SHORT: 1-3 sentences like real conversation
6. Never break character. Never mention AI.
7. Respond in Korean
8. Your personality, flaws, and attitude must show in EVERY line
"""
    
    @staticmethod
    def build_character_section(character: Character) -> str:
        """Build the character information section"""
        sections = []
        
        # Character name and basic info
        sections.append(f"# Character: {character.name}")
        sections.append("")
        
        # Personality
        if character.personality:
            sections.append(f"**Personality:**\n{character.personality}")
            sections.append("")
        
        # Speech style
        if character.speech_style:
            sections.append(f"**Speech Style:**\n{character.speech_style}")
            sections.append("")
        
        # Backstory
        if character.backstory:
            sections.append(f"**Backstory:**\n{character.backstory}")
            sections.append("")
        
        # Scenario context
        if character.scenario:
            sections.append(f"**Current Scenario:**\n{character.scenario}")
            sections.append("")
        
        return "\n".join(sections)
    
    @staticmethod
    def build_example_dialogue(character: Character) -> str:
        """Build example dialogue section"""
        if not character.example_dialogue:
            return ""
        
        return f"""# Example Dialogue

{character.example_dialogue}

Remember to match this style and tone in your responses.
"""
    
    @staticmethod
    def build_user_persona(user_name: str = "User", persona: UserPersona | None = None) -> str:
        """Build user persona section with full details if available"""
        if not persona:
            return f"""# User Information

You are chatting with: {user_name}
"""

        sections = [f"# User Information\n"]
        sections.append(f"You are chatting with: {persona.name}")

        if persona.appearance:
            sections.append(f"\n**Appearance:**\n{persona.appearance}")
        if persona.personality:
            sections.append(f"\n**Personality:**\n{persona.personality}")
        if persona.description:
            sections.append(f"\n**Description:**\n{persona.description}")

        sections.append("\nUse these details to personalize your interactions.")
        return "\n".join(sections)
    
    @staticmethod
    def build_system_prompt(
        character: Character,
        user_name: str = "User",
        include_examples: bool = True,
        persona: UserPersona | None = None,
    ) -> str:
        """
        Build complete system prompt from character card

        Args:
            character: Character model instance
            user_name: Name of the user (default: "User")
            include_examples: Whether to include example dialogue
            persona: User persona for personalized interactions

        Returns:
            Complete system prompt string
        """
        sections = [
            PromptBuilder.SYSTEM_INSTRUCTION,
            PromptBuilder.build_character_section(character),
        ]

        if include_examples and character.example_dialogue:
            sections.append(PromptBuilder.build_example_dialogue(character))

        sections.append(PromptBuilder.build_user_persona(user_name, persona))

        # Final instruction
        sections.append(f"Now, respond as {character.name}. Stay in character!")

        return "\n".join(sections)
    
    @staticmethod
    def build_prompt_with_briefing(
        character: Character,
        briefing: str,
        user_name: str = "User",
        include_examples: bool = True,
        persona: UserPersona | None = None,
    ) -> str:
        """
        Build system prompt with God Agent briefing inserted

        The briefing is placed between character information and conversation context,
        providing the character with current scenario state, knowledge, and emotions.

        Args:
            character: Character model instance
            briefing: God Agent briefing text
            user_name: Name of the user (default: "User")
            include_examples: Whether to include example dialogue
            persona: User persona for personalized interactions

        Returns:
            Complete system prompt with briefing
        """
        sections = [
            PromptBuilder.SYSTEM_INSTRUCTION,
            PromptBuilder.build_character_section(character),
        ]

        if include_examples and character.example_dialogue:
            sections.append(PromptBuilder.build_example_dialogue(character))

        # Insert God Agent briefing
        sections.append("# Current Context Briefing")
        sections.append("")
        sections.append(briefing)
        sections.append("")

        sections.append(PromptBuilder.build_user_persona(user_name, persona))

        # Final instruction
        sections.append(f"Now, respond as {character.name}. Stay in character!")

        return "\n".join(sections)
    
    @staticmethod
    def build_messages(
        character: Character,
        user_message: str,
        conversation_history: list[dict[str, str]] | None = None,
        user_name: str = "User",
    ) -> list[dict[str, str]]:
        """
        Build complete message list for LLM
        
        Args:
            character: Character model instance
            user_message: Current user message
            conversation_history: Previous messages (list of {"role": "user/assistant", "content": "..."})
            user_name: Name of the user
        
        Returns:
            List of message dicts ready for LLM
        """
        messages = []
        
        # System prompt
        system_prompt = PromptBuilder.build_system_prompt(character, user_name)
        messages.append({"role": "system", "content": system_prompt})
        
        # Conversation history
        if conversation_history:
            messages.extend(conversation_history)
        
        # Current user message
        messages.append({"role": "user", "content": user_message})
        
        return messages
