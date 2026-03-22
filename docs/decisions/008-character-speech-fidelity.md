# ADR-008: 캐릭터 말투 충실도를 DB 필드(speech_style + example_dialogue)로 해결

- **Status**: Accepted
- **Date**: 2026-03-22
- **Context**: 딸이 캐릭터 붕괴를 지적 — 나루토가 "다뜨바요"를 안 쓰고, 베지타가 "카카로트"를 안 부르는 등 원작 말버릇이 반영되지 않음. 기존 personality 필드는 성격 설명만 있고, speech_style은 "밝고 활기찬 톤" 수준의 일반적 서술이었음. example_dialogue는 60개 캐릭터 전부 비어있었음.
- **Decision**: characters 테이블의 `speech_style`에 원작 말버릇/구어체/캐치프레이즈를 구체적으로 기술하고, `example_dialogue`에 2-3턴의 실제 대화 예시를 추가. 1:1 채팅(prompt_builder)과 그룹 채팅(God Agent) 양쪽 프롬프트에 이 필드를 포함.
- **Alternatives considered**:
  - LLM 시스템 프롬프트만 강화 → 캐릭터마다 다른 말버릇을 일반 지시문으로 커버 불가
  - 캐릭터별 fine-tuning → 1GB 서버 + Claude CLI 환경에서 불가능, 비용 과다
  - few-shot 예시를 대화 히스토리에 주입 → 토큰 낭비, 매 요청마다 반복
- **Consequences**:
  - 캐릭터 60개 전부 원작 말투 반영 (나루토 "다뜨바요", 루피 "시시시", 프리렌 "...그래?" 등)
  - God Agent 프롬프트에 example_dialogue 300자 포함 → 토큰 사용량 소폭 증가
  - 새 캐릭터 추가 시 speech_style + example_dialogue를 반드시 함께 작성해야 함
  - 캐릭터 자동생성 시에도 이 필드를 채우도록 프롬프트 업데이트 필요 (미구현)
