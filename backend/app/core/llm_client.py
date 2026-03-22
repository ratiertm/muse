"""LLM client with litellm and Claude CLI (OAuth headless) support"""
import asyncio
import json
import logging
import shutil
from typing import AsyncIterator

import litellm
from litellm import acompletion

from app.config import settings

logger = logging.getLogger(__name__)

# Configure litellm
litellm.drop_params = True
litellm.set_verbose = settings.DEBUG


# WHY: API 키 비용 없이 무료로 LLM 사용. CLI fork 오버헤드 있지만 가족 2명 사용엔 충분
# SEE: docs/decisions/002-claude-cli-over-api.md
class ClaudeCLIClient:
    """LLM client that routes calls through 'claude -p' (OAuth headless).
    No API keys needed — uses Claude Code's OAuth session.
    All models are mapped to Claude Sonnet via CLI.
    """

    CLAUDE_BIN = shutil.which("claude") or "claude"

    # Map model names to CLI model flags
    @staticmethod
    def _cli_model(model: str) -> str:
        # 서버 성능 최적화: 모든 요청을 haiku로 처리
        return "haiku"

    async def complete(
        self,
        messages: list[dict[str, str]],
        model: str = "claude-sonnet-4-20250514",
        temperature: float = 0.7,
        max_tokens: int = 300,
        **kwargs,
    ) -> str:
        prompt = self._messages_to_prompt(messages)
        cmd = [
            self.CLAUDE_BIN, "-p",
            "--model", self._cli_model(model),
            "--output-format", "text",
            "--no-session-persistence",
            "--plugin-dir", "/tmp/muse-empty-plugins",
            "--system-prompt", "You are a roleplay AI. Respond in character. Keep responses SHORT: 1-2 sentences max. Korean only. No explanations.",
        ]

        logger.debug(f"Claude CLI complete: {len(prompt)} chars")

        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd="/tmp",
            env={**__import__('os').environ, "CLAUDE_PLUGIN_DIRS": ""},
        )
        stdout, stderr = await proc.communicate(prompt.encode())

        if proc.returncode != 0:
            err = stderr.decode().strip()
            logger.error(f"Claude CLI error: {err}")
            raise RuntimeError(f"Claude CLI failed: {err[:200]}")

        return self._clean_output(stdout.decode().strip())

    @staticmethod
    def _clean_output(text: str) -> str:
        """Remove bkit/plugin artifacts from Claude CLI output"""
        # Cut at bkit feature usage report
        for marker in ["─────", "📊 bkit", "✅ Used:", "⏭️ Not Used:", "💡 Recommended:"]:
            idx = text.find(marker)
            if idx > 0:
                text = text[:idx].rstrip()
        return text

    async def stream(
        self,
        messages: list[dict[str, str]],
        model: str = "claude-sonnet-4-20250514",
        temperature: float = 0.7,
        max_tokens: int = 300,
        **kwargs,
    ) -> AsyncIterator[str]:
        prompt = self._messages_to_prompt(messages)
        # stream-json requires --verbose
        cmd = [
            self.CLAUDE_BIN, "-p",
            "--model", self._cli_model(model),
            "--output-format", "stream-json",
            "--verbose",
            "--no-session-persistence",
            "--plugin-dir", "/tmp/muse-empty-plugins",
            "--system-prompt", "You are a roleplay AI. Respond in character. Keep responses SHORT: 1-2 sentences max. Korean only. No explanations.",
        ]

        logger.debug(f"Claude CLI stream: {len(prompt)} chars")

        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd="/tmp",
            env={**__import__('os').environ, "CLAUDE_PLUGIN_DIRS": ""},
        )

        # Send prompt and close stdin
        proc.stdin.write(prompt.encode())
        await proc.stdin.drain()
        proc.stdin.close()

        result_emitted = False

        # Stream stdout line by line
        while True:
            line = await proc.stdout.readline()
            if not line:
                break

            line_str = line.decode().strip()
            if not line_str:
                continue

            try:
                event = json.loads(line_str)
                event_type = event.get("type", "")

                # assistant message with content array containing text blocks
                if event_type == "assistant":
                    msg = event.get("message", {})
                    for block in msg.get("content", []):
                        if block.get("type") == "text":
                            text = block.get("text", "")
                            if text:
                                cleaned = self._clean_output(text)
                                if cleaned:
                                    yield cleaned
                                    result_emitted = True

                # Final result — fallback if assistant events didn't yield
                elif event_type == "result" and not result_emitted:
                    result_text = event.get("result", "")
                    if result_text:
                        yield self._clean_output(result_text)

            except json.JSONDecodeError:
                continue

        await proc.wait()

    @staticmethod
    def _messages_to_prompt(messages: list[dict[str, str]]) -> str:
        """Convert chat messages to a single prompt for claude -p"""
        parts = []
        for msg in messages:
            role = msg["role"]
            content = msg["content"]
            if role == "system":
                parts.append(f"[System Instructions]\n{content}\n")
            elif role == "user":
                parts.append(f"[User]\n{content}\n")
            elif role == "assistant":
                parts.append(f"[Assistant]\n{content}\n")
        return "\n".join(parts)


class LiteLLMClient:
    """Standard LLM client using litellm with API keys"""

    GPT4O_MINI = "gpt-4o-mini"
    CLAUDE_SONNET = "claude-sonnet-4-20250514"

    def __init__(self):
        if settings.OPENAI_API_KEY:
            litellm.openai_key = settings.OPENAI_API_KEY
        if settings.ANTHROPIC_API_KEY:
            litellm.anthropic_key = settings.ANTHROPIC_API_KEY

    async def complete(
        self,
        messages: list[dict[str, str]],
        model: str = GPT4O_MINI,
        temperature: float = 0.7,
        max_tokens: int = 300,
        **kwargs,
    ) -> str:
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
        max_tokens: int = 300,
        **kwargs,
    ) -> AsyncIterator[str]:
        response = await acompletion(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            stream=True,
            **kwargs,
        )
        async for chunk in response:
            if hasattr(chunk, 'choices') and len(chunk.choices) > 0:
                delta = chunk.choices[0].delta
                if hasattr(delta, 'content') and delta.content:
                    yield delta.content


# Type alias for backward compatibility (used in god_agent.py, auto_generator.py)
LLMClient = ClaudeCLIClient if settings.USE_CLAUDE_CLI else LiteLLMClient

# Select client based on config
if settings.USE_CLAUDE_CLI:
    logger.info("Using Claude CLI (OAuth headless) for LLM calls")
    llm_client = ClaudeCLIClient()
else:
    llm_client = LiteLLMClient()
