# PROJECT.md — Muse

## Vision
대학생 딸을 위한 개인용 AI 캐릭터 채팅 앱. 소설 속 캐릭터를 재현하거나 오리지널 캐릭터를 창작하고, 만든 캐릭터와 자유롭게 대화할 수 있다. 제타/크랙 수준의 경험을 심플하고 깔끔한 UI로 제공.

## Core Value
**딸이 직접 캐릭터를 만들고 대화하는 것** — 이것이 되면 나머지는 부가기능.

## Target User
- MB + 딸 (2인, 가족용)
- Android 사용자
- 딸: 애니 (죠죠 등), MB: 클래식 소설 (홈즈, 루팡)

## Key Features
- 캐릭터 생성 (이름, 성격, 말투, 배경스토리, 예시대화)
- 1:1 채팅 (캐릭터와 대화, 맥락 유지)
- 그룹 채팅 (캐릭터 여러 명이 동시 대화)
- 캐릭터 프로필 이미지 AI 생성 (애니풍)
- 대화 기록 서버 저장
- 멀티 프로필 (유저별 캐릭터/대화 분리)
- 원작 기반 캐릭터 자동 생성 (작품명+캐릭터명 → AI가 설정 채움)
- **God Agent 시스템** (핵심 차별점)

## Architecture: God Agent
Muse의 핵심 설계. 전지적 시점의 오케스트레이터가 세계관과 모든 캐릭터를 관장.

### 역할
- 세계 상태(시간축, 장소, 이벤트) 관리
- 각 캐릭터가 "무엇을 알고 무엇을 모르는지" 판단
- 대화 전 캐릭터에게 브리핑 (knowledge-aware prompting)
- 대화 후 세계 상태 업데이트 (이벤트 추출, 지식 전파)
- 그룹챗 턴 오케스트레이션

### 3계층 지식 구조
- World State: 시나리오 공통 상태 (시간, 장소, 공개 이벤트)
- Knowledge Graph: 캐릭터별 "아는 것/모르는 것" 맵
- Private State: 캐릭터 개인 감정, 비밀, 속마음

### LLM 파이프라인 (1턴)
1. 유저 메시지 수신
2. God Agent (GPT-4o-mini) → 캐릭터 브리핑 생성
3. Character Agent (Claude Sonnet) → 응답 생성
4. God Agent (GPT-4o-mini) → 세계 상태 업데이트

## Tech Decisions
- **앱:** Flutter (Android, 추후 iOS 확장 가능)
- **백엔드:** FastAPI (Python)
- **LLM:** GPT-4o-mini + Claude Sonnet (둘 다 지원)
- **이미지 생성:** 애니풍 (Stable Diffusion / DALL-E)
- **서버:** 오라클 춘천 프리티어
- **DB:** PostgreSQL
- **배포:** APK 직접 설치

## Design
- 깔끔한 UI, 미니멀
- 다크/라이트 테마
- 앱 이름: **Muse**

## Constraints
- 개인 사용 (1인 유저)
- 월 운영비 $5~15 수준
- 스토어 배포 불필요
