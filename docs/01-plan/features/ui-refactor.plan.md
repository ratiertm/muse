# UI/UX Refactor Plan

## Feature: ui-refactor
## Date: 2026-03-21
## Status: Plan

---

## 1. Overview

Muse 앱의 네비게이션 구조를 Drawer 기반에서 BottomNavigationBar 기반으로 전환하고,
전체 화면 간 이동 동선을 개선하는 UI/UX 리팩토링.

### Target Users
- 가족 구성원 (부모 + 딸), 캐주얼 애니메이션 팬

### Core Problem
1. Drawer에 모든 기능이 숨어있어 발견성(discoverability) 극히 낮음
2. `context.go()` 사용으로 화면 스택이 초기화되어 뒤로가기 불안정
3. 로그아웃/나가기가 찾기 어려운 위치에 배치

---

## 2. Implementation Plan

### P0 - Critical (사용성 블로커)

#### P0-1: BottomNavigationBar 도입
- **현재**: Drawer에 6개 메뉴 항목
- **변경**: 4탭 BottomNav (대화 / 캐릭터 / 시나리오 / 내 정보)
- **작업 내용**:
  - [ ] `MainShell` 위젯 생성 (BottomNavigationBar 포함)
  - [ ] GoRouter에 `StatefulShellRoute` 도입
  - [ ] CharacterListScreen에서 Drawer 제거
  - [ ] 각 탭의 AppBar 정리

#### P0-2: Back Navigation 수정
- **현재**: `context.go()` 사용으로 스택 초기화
- **변경**: `context.push()` 또는 `context.pushReplacement()` 사용
- **작업 내용**:
  - [ ] `group_create_screen.dart:106` - `go` → `pushReplacement`
  - [ ] 모든 하위 화면에 명시적 뒤로가기 버튼 확인
  - [ ] ChatScreen pop 실패 시 fallback 추가

#### P0-3: 로그아웃 동선 개선
- **현재**: AppBar 아이콘 + Settings 하단에 중복
- **변경**: "내 정보" 탭에 프로필 카드 + 프로필 전환/로그아웃 배치
- **작업 내용**:
  - [ ] CharacterListScreen AppBar에서 logout 아이콘 제거
  - [ ] "내 정보" 탭 화면 구성 (ProfileScreen)
  - [ ] 프로필 전환, 페르소나, 설정, 로그아웃 통합

### P1 - Important (구조 개선)

#### P1-4: GoRouter 계층 구조 리팩토링
- **현재**: 14개 라우트가 플랫 구조
- **변경**: ShellRoute 안에 탭별 하위 라우트 그룹핑
- **작업 내용**:
  - [ ] StatefulShellRoute.indexedStack 도입
  - [ ] 각 탭별 NavigatorKey 분리
  - [ ] 인증 라우트(profile-selection, pin-auth) 분리

#### P1-5: ConversationList를 홈 탭으로 승격
- **현재**: 홈이 CharacterListScreen
- **변경**: 대화 목록이 첫 번째 탭
- **작업 내용**:
  - [ ] ConversationListScreen을 탭 1로 배치
  - [ ] 대화 카드에 마지막 메시지 미리보기 추가
  - [ ] 새 대화 시작 FAB 추가

#### P1-6: 그룹채팅 진입점 정리
- **현재**: Drawer 메뉴 항목
- **변경**: 대화 탭 FAB에서 1:1/그룹 선택
- **작업 내용**:
  - [ ] ConversationList FAB → BottomSheet (1:1 대화 / 그룹 채팅)
  - [ ] 시나리오 목록에서 "이 시나리오로 시작" 옵션

---

## 3. Affected Files

### 신규 생성
- `frontend/lib/presentation/screens/main_shell.dart` (BottomNav 쉘)
- `frontend/lib/presentation/screens/profile/profile_screen.dart` (내 정보 탭)

### 주요 수정
- `frontend/lib/core/router/app_router.dart` (라우터 전면 재구성)
- `frontend/lib/presentation/screens/character_list/character_list_screen.dart` (Drawer 제거)
- `frontend/lib/presentation/screens/conversation_list/conversation_list_screen.dart` (홈 승격)
- `frontend/lib/presentation/screens/group_create/group_create_screen.dart` (go→push)
- `frontend/lib/presentation/screens/settings/settings_screen.dart` (내 정보에 통합)
- `frontend/lib/presentation/screens/scenario_list/scenario_list_screen.dart` (바로 시작 추가)

---

## 4. Success Criteria

- [ ] BottomNav 4탭으로 모든 주요 기능에 1탭 이내로 접근 가능
- [ ] 모든 화면에서 뒤로가기(물리 버튼 + AppBar) 정상 동작
- [ ] 로그아웃이 "내 정보" 탭에서 즉시 접근 가능
- [ ] 기존 기능 (채팅, 시나리오, 캐릭터 관리) 모두 정상 동작
- [ ] 화면 캡처로 각 단계 검증 완료

---

## 5. Risk

- GoRouter StatefulShellRoute 전환 시 기존 push/pop 동작 변경
- 탭 간 상태 유지 검증 필요
- 화면 전환 애니메이션 변경 가능
