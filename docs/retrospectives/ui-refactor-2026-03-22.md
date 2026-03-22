# Phase Retrospective: UI/UX Refactor + Oracle Cloud Deploy

- **Date**: 2026-03-22
- **Phase**: ui-refactor
- **Duration**: 2026-03-21 → 2026-03-22

## What Went Well
- BottomNav 4탭 전환이 UX를 크게 개선. 딸이 바로 적응
- 시나리오 바텀시트 인라인 채팅 생성 — 동선 단축 효과적
- 로컬 아바타 저장으로 이미지 깨짐 완전 해결
- Oracle Cloud 배포 성공 (1GB RAM에서도 동작)
- 대화 목록 그룹핑으로 깔끔한 목록 달성

## What Went Wrong
- **Jikan 이미지 검색 정확도 낮음** — 한글 이름으로 검색하면 엉뚱한 캐릭터 매칭됨. 베지타에 다른 캐릭터 이미지가 들어감. 영문 이름 + 애니 이름으로 검색해야 정확
- **에뮬레이터 PIN 로그인 실패** — release APK의 `usesCleartextTraffic` 설정이 빠져서 HTTP 통신 차단. 디버깅에 30분+ 소요
- **Material 3 스트레치 오버스크롤** — 모든 리스트에서 드래그 시 카드가 늘어남. 전역 ScrollBehavior 교체 필요했는데 늦게 발견
- **그룹채팅 만들기 오류** — 시나리오-캐릭터 연결이 없어서 빈 캐릭터 목록 표시

## What Was Surprising
- Claude CLI OAuth가 서버에서도 작동함 (headless 환경에서 URL 복사 인증)
- 1GB RAM + 2GB swap으로 PostgreSQL + FastAPI + Claude CLI 동시 운영 가능
- Flutter release APK와 debug APK의 네트워크 정책이 다름
- 캐릭터 60개 이미지 다운로드 시 Jikan API rate limit (3초 간격 필요)

## Key Decisions Made
- ADR-001: Drawer → BottomNav → [001](../decisions/001-bottom-nav-over-drawer.md)
- ADR-002: Claude CLI OAuth → [002](../decisions/002-claude-cli-over-api.md)
- ADR-003: 로컬 아바타 저장 → [003](../decisions/003-local-avatar-storage.md)
- ADR-004: God Agent 패턴 → [004](../decisions/004-god-agent-group-chat.md)
- ADR-005: Oracle Cloud 1GB 배포 → [005](../decisions/005-oracle-cloud-1gb-deploy.md)
- ADR-006: 시나리오 인라인 채팅 → [006](../decisions/006-scenario-inline-chat-creation.md)
- ADR-007: 대화 그룹핑 → [007](../decisions/007-conversation-grouping.md)

## Technical Debt Introduced
- Claude CLI OAuth 7일 만료 → 수동 재인증 필요. 상용화 시 API 키 전환 필수
- 캐릭터 이미지 일부 불일치 — 영문 이름 매핑 테이블 필요
- 그룹채팅 God Agent의 캐릭터 선택 정확도 — 가끔 엉뚱한 캐릭터 응답
- `is_public` 토글 UI 미구현 — 현재 모든 콘텐츠가 공용

## Lessons for Next Phase
- **이미지 검색은 반드시 영문 이름 + 원작 이름으로** — 한글 검색 절대 금지
- **release APK 테스트는 실제 네트워크 환경에서** — 에뮬레이터 localhost와 실서버는 다름
- **Flutter Material 3 기본값 확인** — 오버스크롤, 테마 등 의도치 않은 동작 다수
- **서버 메모리 모니터링 필수** — `free -h` 주기적 확인, OOM 킬 대비
- **시나리오-캐릭터 관계는 DB에서 확인 후 작업** — 프론트에서 빈 리스트 오류 방지

## Metrics
- Commits: 7
- Files changed: 30+
- ADRs created: 7
- Bugs found during phase: 6 (PIN 로그인, 오버스크롤, 이미지 불일치, 그룹채팅 오류, 대화 미갱신, 메시지창 위치)
- Bugs fixed: 5 (이미지 불일치 일부 미해결)
