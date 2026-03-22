# ADR-001: Drawer → BottomNavigationBar 4탭 전환

- **Status**: Accepted
- **Date**: 2026-03-21
- **Context**: 기존 Drawer 네비게이션이 탭 접근성이 떨어지고, 한 손 조작이 불편함. 딸(10대)이 주 사용자인데 Drawer는 발견성이 낮음.
- **Decision**: BottomNavigationBar 4탭 (채팅/캐릭터/시나리오/내 정보) + GoRouter StatefulShellRoute 적용
- **Alternatives considered**:
  - Drawer 유지 + 개선 → 발견성 문제 해결 안 됨
  - TabBar (상단) → Material 3 가이드라인과 불일치, 엄지 접근 불편
- **Consequences**:
  - 각 탭이 독립 Navigator를 가져 상태 보존됨
  - full-screen route (채팅, 그룹채팅)는 shell 밖으로 빠짐
  - 탭 전환 시 이전 스크롤 위치 유지
