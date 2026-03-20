# PROJECT.md — Muse

## Vision
대학생 딸을 위한 개인용 AI 캐릭터 채팅 앱. 소설 속 캐릭터를 재현하거나 오리지널 캐릭터를 창작하고, 만든 캐릭터와 자유롭게 대화할 수 있다. 제타/크랙 수준의 경험을 심플하고 깔끔한 UI로 제공.

## Core Value
**딸이 직접 캐릭터를 만들고 대화하는 것** — 이것이 되면 나머지는 부가기능.

## Target User
- 대학생 (1명, 딸 전용)
- Android 사용자

## Key Features
- 캐릭터 생성 (이름, 성격, 말투, 배경스토리, 예시대화)
- 1:1 채팅 (캐릭터와 대화, 맥락 유지)
- 그룹 채팅 (캐릭터 여러 명이 동시 대화)
- 캐릭터 프로필 이미지 AI 생성 (애니풍)
- 대화 기록 서버 저장

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
