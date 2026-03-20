"""Character auto-generator from source works using LLM"""
import json
import logging
from typing import Dict, Any

from app.core.llm_client import llm_client, LLMClient
from app.schemas.character import CharacterCreate

logger = logging.getLogger(__name__)


class CharacterAutoGenerator:
    """Generate character cards from source work + character name"""
    
    GENERATION_PROMPT = """You are a character expert who creates detailed character cards.

Given a source work and character name, generate a complete character profile.

Source Work: {source_work}
Character Name: {character_name}

Generate a JSON object with these fields (ALL TEXT IN KOREAN):

{{
  "name": "{character_name}",
  "personality": "3-5 문장으로 캐릭터의 성격 특성을 설명 (예: 냉정하고 계산적이며...)",
  "speech_style": "2-3 문장으로 말투와 어투를 설명 (예: 격식체를 사용하며...)",
  "backstory": "1-2 문단으로 캐릭터의 배경 스토리 (작품 기반)",
  "scenario": "기본 대화 상황 설정 (예: 당신은 {character_name}를 우연히 만났다...)",
  "first_message": "캐릭터가 첫 대화에서 할 인사말 (인용부호 없이, 캐릭터 말투로)",
  "example_dialogue": "3-5개의 대화 예시 (User: ... {character_name}: ... 형식)",
  "tags": ["작품명", "캐릭터타입", "관련태그1", "관련태그2"]
}}

Rules:
1. Be faithful to the original character from the source work
2. Use Korean for all text fields
3. Keep personality and speech_style concise but detailed
4. Make first_message natural and in-character
5. Example dialogue should show the character's personality
6. Tags should include source work name and character traits
7. Return ONLY valid JSON, no markdown or extra text

Generate the character card now:"""
    
    def __init__(self, llm_client_instance: LLMClient | None = None):
        """Initialize auto-generator with LLM client"""
        self.llm = llm_client_instance or llm_client
    
    async def generate_from_source(
        self,
        source_work: str,
        character_name: str,
    ) -> CharacterCreate:
        """
        Generate a character card from source work and character name
        
        Args:
            source_work: Name of the source work (e.g., "죠죠의 기묘한 모험")
            character_name: Name of the character (e.g., "디오")
        
        Returns:
            CharacterCreate schema ready for saving
        
        Raises:
            ValueError: If generation fails or response is invalid
        """
        logger.info(f"Auto-generating character: {character_name} from {source_work}")
        
        # Build prompt
        prompt = self.GENERATION_PROMPT.format(
            source_work=source_work,
            character_name=character_name,
        )
        
        messages = [
            {"role": "system", "content": "You are a helpful assistant that generates character profiles in JSON format."},
            {"role": "user", "content": prompt},
        ]
        
        try:
            # Generate with GPT-4o-mini (faster and cheaper for structured output)
            response = await self.llm.complete(
                messages=messages,
                model=LLMClient.GPT4O_MINI,
                temperature=0.7,
                max_tokens=2000,
            )
            
            logger.debug(f"LLM response: {response}")
            
            # Parse JSON response
            character_data = self._parse_json_response(response)
            
            # Validate and create CharacterCreate instance
            character = CharacterCreate(**character_data)
            
            logger.info(f"Successfully generated character: {character.name}")
            return character
            
        except Exception as e:
            logger.error(f"Failed to auto-generate character: {e}")
            raise ValueError(f"캐릭터 자동 생성 실패: {str(e)}")
    
    def _parse_json_response(self, response: str) -> Dict[str, Any]:
        """
        Parse JSON from LLM response (handles markdown code blocks)
        
        Args:
            response: Raw LLM response
        
        Returns:
            Parsed JSON dict
        
        Raises:
            ValueError: If JSON parsing fails
        """
        # Remove markdown code blocks if present
        cleaned = response.strip()
        
        if cleaned.startswith("```json"):
            cleaned = cleaned[7:]  # Remove ```json
        elif cleaned.startswith("```"):
            cleaned = cleaned[3:]  # Remove ```
        
        if cleaned.endswith("```"):
            cleaned = cleaned[:-3]  # Remove closing ```
        
        cleaned = cleaned.strip()
        
        try:
            data = json.loads(cleaned)
            return data
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON: {e}\nResponse: {cleaned}")
            raise ValueError(f"JSON 파싱 실패: {str(e)}")


# Global instance
auto_generator = CharacterAutoGenerator()
