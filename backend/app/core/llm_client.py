"""LiteLLM client wrapper for async LLM operations with streaming support"""
from typing import AsyncIterator
import litellm
from litellm import acompletion

from app.config import settings

# Configure litellm
litellm.drop_params = True  # Drop unsupported params instead of error
litellm.set_verbose = settings.DEBUG


class LLMClient:
    """Async LLM client using litellm with streaming support"""
    
    # Supported models
    GPT4O_MINI = "gpt-4o-mini"
    CLAUDE_SONNET = "claude-sonnet-4-20250514"
    
    def __init__(self):
        """Initialize LLM client"""
        # Set API keys
        if settings.OPENAI_API_KEY:
            litellm.openai_key = settings.OPENAI_API_KEY
        if settings.ANTHROPIC_API_KEY:
            litellm.anthropic_key = settings.ANTHROPIC_API_KEY
    
    async def complete(
        self,
        messages: list[dict[str, str]],
        model: str = GPT4O_MINI,
        temperature: float = 0.7,
        max_tokens: int = 1000,
        **kwargs,
    ) -> str:
        """
        Complete a chat conversation (non-streaming)
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            model: Model identifier (gpt-4o-mini, claude-sonnet-4-20250514, etc.)
            temperature: Sampling temperature (0.0-2.0)
            max_tokens: Maximum tokens to generate
            **kwargs: Additional litellm parameters
        
        Returns:
            Generated text response
        """
        response = await acompletion(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=False,
            **kwargs,
        )
        
        return response.choices[0].message.content
    
    async def stream(
        self,
        messages: list[dict[str, str]],
        model: str = GPT4O_MINI,
        temperature: float = 0.7,
        max_tokens: int = 1000,
        **kwargs,
    ) -> AsyncIterator[str]:
        """
        Stream a chat conversation response
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            model: Model identifier
            temperature: Sampling temperature (0.0-2.0)
            max_tokens: Maximum tokens to generate
            **kwargs: Additional litellm parameters
        
        Yields:
            Text chunks as they are generated
        """
        response = await acompletion(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=True,
            **kwargs,
        )
        
        async for chunk in response:
            # Extract content delta from chunk
            if hasattr(chunk, 'choices') and len(chunk.choices) > 0:
                delta = chunk.choices[0].delta
                if hasattr(delta, 'content') and delta.content:
                    yield delta.content


# Global client instance
llm_client = LLMClient()
