# ADR-002: Anthropic API 대신 Claude CLI 사용

- **Status**: Accepted (임시)
- **Date**: 2026-03-22
- **Context**: LLM 호출이 필요하나 API 키 비용을 지불하기 어려운 상황. 개인/가족 프로젝트라 월 $50+ API 비용이 부담.
- **Decision**: `claude -p` CLI를 OAuth 인증으로 사용. 모델 매핑: sonnet(대화), haiku(자동생성)
- **Alternatives considered**:
  - Anthropic API 직접 호출 → 비용 문제
  - OpenAI API → 롤플레이 품질이 Claude보다 낮음
  - 로컬 LLM (Ollama) → 서버 1GB RAM으로 불가능
- **Consequences**:
  - 무료이지만 OAuth 7일마다 재인증 필요
  - CLI 프로세스 fork 오버헤드로 응답 2~3초 지연
  - 상용화 시 반드시 API 키로 전환 필요
- **Risk**: Claude CLI OAuth는 상업용이 아님. 대량 트래픽 시 제한될 수 있음
