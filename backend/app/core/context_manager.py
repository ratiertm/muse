"""Context window management for maintaining conversation history within token limits"""
from typing import Literal

from app.models.message import Message, MessageRole


class ContextManager:
    """Manage conversation context with sliding window"""
    
    # Rough token estimation (1 token ≈ 4 characters for English, 2-3 for efficient encoding)
    CHARS_PER_TOKEN = 3.5
    
    @staticmethod
    def estimate_tokens(text: str) -> int:
        """Estimate token count from text length"""
        return int(len(text) / ContextManager.CHARS_PER_TOKEN)
    
    @staticmethod
    def build_conversation_history(
        messages: list[Message],
        max_tokens: int = 4000,
        preserve_system: bool = True,
    ) -> list[dict[str, str]]:
        """
        Build conversation history with sliding window to fit within token limit
        
        Args:
            messages: List of Message objects (should be in chronological order)
            max_tokens: Maximum total tokens for message history
            preserve_system: If True, preserve system messages at any cost
        
        Returns:
            List of message dicts ready for LLM ({"role": "user/assistant/system", "content": "..."})
        """
        if not messages:
            return []
        
        result = []
        total_tokens = 0
        
        # Separate system messages and regular messages
        system_messages = [msg for msg in messages if msg.role == MessageRole.SYSTEM]
        regular_messages = [msg for msg in messages if msg.role != MessageRole.SYSTEM]
        
        # Always include system messages first if preserve_system is True
        if preserve_system:
            for msg in system_messages:
                msg_dict = {"role": msg.role.value, "content": msg.content}
                tokens = msg.token_count or ContextManager.estimate_tokens(msg.content)
                result.append(msg_dict)
                total_tokens += tokens
        
        # Add regular messages from oldest to newest, but truncate from the beginning if needed
        messages_to_add = []
        tokens_needed = 0
        
        # Calculate tokens for all regular messages (newest to oldest)
        for msg in reversed(regular_messages):
            tokens = msg.token_count or ContextManager.estimate_tokens(msg.content)
            messages_to_add.insert(0, (msg, tokens))
            tokens_needed += tokens
            
            # Stop if we've collected enough messages to fill the window
            if total_tokens + tokens_needed > max_tokens:
                break
        
        # Add as many recent messages as fit in the window
        remaining_tokens = max_tokens - total_tokens
        for msg, tokens in reversed(messages_to_add):
            if tokens <= remaining_tokens:
                result.append({"role": msg.role.value, "content": msg.content})
                remaining_tokens -= tokens
            else:
                # Stop once we can't fit any more
                break
        
        return result
    
    @staticmethod
    def prepare_context_messages(
        system_prompt: str,
        conversation_history: list[Message],
        max_history_tokens: int = 3000,
    ) -> list[dict[str, str]]:
        """
        Prepare complete context with system prompt + sliding window history
        
        Args:
            system_prompt: System prompt to prepend
            conversation_history: List of Message objects
            max_history_tokens: Maximum tokens for history (not counting system prompt)
        
        Returns:
            Complete message list with system prompt + recent history
        """
        messages = []
        
        # Add system prompt
        messages.append({"role": "system", "content": system_prompt})
        
        # Add conversation history with sliding window
        if conversation_history:
            history_messages = ContextManager.build_conversation_history(
                messages=conversation_history,
                max_tokens=max_history_tokens,
                preserve_system=False,  # We already added system prompt above
            )
            messages.extend(history_messages)
        
        return messages
