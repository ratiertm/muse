"""Avatar generator using DALL-E 3 for anime-style character portraits"""
import logging
from openai import AsyncOpenAI

from app.config import settings
from app.models.character import Character

logger = logging.getLogger(__name__)


class AvatarGenerator:
    """Generate anime-style avatars using DALL-E 3"""
    
    def __init__(self):
        """Initialize avatar generator with OpenAI client"""
        if not settings.OPENAI_API_KEY:
            raise ValueError("OPENAI_API_KEY is required for avatar generation")
        
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
    
    async def generate_avatar(self, character: Character) -> str:
        """
        Generate an anime-style avatar for a character
        
        Args:
            character: Character model instance
        
        Returns:
            Image URL from DALL-E 3
        
        Raises:
            Exception: If image generation fails
        """
        logger.info(f"Generating avatar for character: {character.name}")
        
        # Build DALL-E prompt from character traits
        prompt = self._build_prompt(character)
        
        logger.debug(f"DALL-E prompt: {prompt}")
        
        try:
            response = await self.client.images.generate(
                model="dall-e-3",
                prompt=prompt,
                size="1024x1024",
                quality="standard",
                n=1,
            )
            
            image_url = response.data[0].url
            
            logger.info(f"Avatar generated successfully: {image_url}")
            return image_url
            
        except Exception as e:
            logger.error(f"Failed to generate avatar: {e}")
            raise Exception(f"아바타 생성 실패: {str(e)}")
    
    def _build_prompt(self, character: Character) -> str:
        """
        Build DALL-E prompt from character data
        
        Creates a detailed anime-style portrait prompt based on:
        - Character name
        - Personality traits
        - Backstory elements
        
        Args:
            character: Character model instance
        
        Returns:
            DALL-E prompt string
        """
        # Extract key traits from personality (first 100 chars for brevity)
        personality_snippet = character.personality[:100] if character.personality else "mysterious"
        
        # Build prompt
        prompt = (
            f"Anime-style portrait of {character.name}. "
            f"{personality_snippet}. "
            f"High quality, detailed, colorful, 1024x1024, anime art style, "
            f"upper body shot, clean background, vibrant colors, expressive eyes."
        )
        
        # Ensure prompt is not too long (DALL-E 3 limit is 4000 chars)
        if len(prompt) > 1000:
            prompt = prompt[:1000]
        
        return prompt


# Lazy-initialized global instance
_avatar_generator: AvatarGenerator | None = None


def get_avatar_generator() -> AvatarGenerator:
    """Get or create the avatar generator instance (lazy init)"""
    global _avatar_generator
    if _avatar_generator is None:
        _avatar_generator = AvatarGenerator()
    return _avatar_generator
