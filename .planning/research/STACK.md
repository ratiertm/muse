# 기술 스택 리서치: AI 캐릭터 챗 앱 (Flutter + FastAPI)

## 1. Flutter 프론트엔드

### 상태 관리
| 패키지 | 추천도 | 특징 |
|--------|--------|------|
| **Riverpod 3.x** | ⭐⭐⭐⭐⭐ | 2026년 기준 최고 추천. 선언적, 의존성 추적 우수, 불필요한 리빌드 최소화 |
| **flutter_bloc / Cubit** | ⭐⭐⭐⭐ | 엔터프라이즈급 프로젝트에 적합. 이벤트 기반 아키텍처 |
| **Signals** | ⭐⭐⭐ | Flutter 네이티브, 성능 우수하나 생태계 미성숙 |

**추천**: Riverpod 3 + Freezed (불변 데이터 모델) + riverpod_generator

### 채팅 UI 패키지
| 패키지 | pub.dev | 특징 |
|--------|---------|------|
| **flutter_chat_ui** | ✅ 인기 최고 | Flyer Chat 팀 제작. 커스터마이징 자유도 높음. 메시지 타입 확장 가능 |
| **dash_chat_2** | ✅ | 간단한 API, 빠른 프로토타이핑에 적합 |
| **chat_bubbles** | ✅ | WhatsApp 스타일 버블, 오디오/이미지 버블 포함 |
| **커스텀 구현** | - | AI 챗 특화 기능(스트리밍, 타이핑 애니메이션)이 필요하면 직접 구현 권장 |

**추천**: `flutter_chat_ui`를 베이스로 커스터마이징하거나, AI 챗에 최적화된 커스텀 위젯 직접 구현
- AI 스트리밍 응답 표시 (글자 단위 타이핑 효과)
- 캐릭터 아바타 + 이름 표시
- 마크다운 렌더링 (이탈릭 = 행동묘사, 일반텍스트 = 대사)

### API / 네트워크
| 패키지 | 용도 |
|--------|------|
| **dio** | HTTP 클라이언트 (인터셉터, 리트라이 지원) |
| **flutter_client_sse** / **eventsource** | SSE 스트리밍 수신 |
| **web_socket_channel** | WebSocket 양방향 통신 (실시간 그룹채팅) |
| **retrofit** | Dio 기반 타입세이프 API 클라이언트 생성 |

### 로컬 저장소
| 패키지 | 용도 |
|--------|------|
| **drift (moor)** | SQLite ORM. 채팅 히스토리 로컬 캐싱 |
| **hive** / **isar** | NoSQL. 경량 설정/캐릭터 카드 저장 |
| **shared_preferences** | 간단한 설정값 |

### 기타 필수 패키지
- **cached_network_image**: 캐릭터 이미지 캐싱
- **flutter_markdown**: AI 응답 마크다운 렌더링
- **shimmer**: 로딩 스켈레톤
- **go_router**: 네비게이션
- **flutter_animate**: 트랜지션 애니메이션

---

## 2. FastAPI 백엔드

### 프로젝트 구조 (권장)
```
backend/
├── app/
│   ├── main.py                 # FastAPI 앱 인스턴스
│   ├── config.py               # 설정 (환경변수, API 키)
│   ├── dependencies.py         # DI 의존성
│   ├── api/
│   │   ├── v1/
│   │   │   ├── chat.py         # 채팅 엔드포인트
│   │   │   ├── characters.py   # 캐릭터 CRUD
│   │   │   ├── users.py        # 유저 관리
│   │   │   └── images.py       # 이미지 생성
│   ├── core/
│   │   ├── llm_client.py       # LLM API 프록시 (OpenAI/Claude/로컬)
│   │   ├── prompt_builder.py   # 프롬프트 조립 엔진
│   │   ├── memory_manager.py   # 컨텍스트/메모리 관리
│   │   ├── rate_limiter.py     # 요청 제한
│   │   └── safety_filter.py    # 프롬프트 인젝션 방어
│   ├── models/
│   │   ├── character.py        # 캐릭터 DB 모델
│   │   ├── chat.py             # 채팅/메시지 모델
│   │   └── user.py             # 유저 모델
│   ├── schemas/
│   │   ├── chat.py             # Pydantic 요청/응답 스키마
│   │   └── character.py
│   ├── services/
│   │   ├── chat_service.py     # 채팅 비즈니스 로직
│   │   ├── character_service.py
│   │   └── image_service.py    # 이미지 생성 서비스
│   └── db/
│       ├── database.py         # DB 연결 (async SQLAlchemy / Tortoise)
│       └── migrations/
├── tests/
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

### 핵심 기술 선택
| 영역 | 기술 | 이유 |
|------|------|------|
| **ASGI 서버** | uvicorn + gunicorn | 비동기 처리 필수 |
| **LLM 프록시** | litellm 또는 직접 httpx async | 다중 LLM 벤더 통합 (OpenAI, Claude, 로컬 모델) |
| **스트리밍** | SSE (sse-starlette) | LLM 토큰 스트리밍에 최적. WebSocket보다 단순 |
| **DB** | PostgreSQL + async SQLAlchemy | 채팅 히스토리, 유저 데이터 |
| **캐시** | Redis | 세션, 레이트리밋, 활성 컨텍스트 캐싱 |
| **벡터 DB** | pgvector / Qdrant / ChromaDB | 캐릭터 장기 기억 (RAG) |
| **태스크 큐** | Celery / ARQ | 이미지 생성 등 무거운 작업 비동기 처리 |
| **인증** | JWT (python-jose) | 모바일 앱 토큰 인증 |

### LLM 선택지
| 모델 | 특징 | 비용 |
|------|------|------|
| **Claude 3.5 Sonnet / 3.7** | 롤플레이 최강. 크랙이 실제 사용 중 | 중간 |
| **GPT-4o-mini** | 가성비. 빠른 응답 | 저렴 |
| **Gemini 2.0 Flash** | 무료 티어 가능, 빠름 | 매우 저렴 |
| **로컬 모델 (Mistral, Qwen)** | 비용 0. 하드웨어 필요 | GPU 비용 |

### SSE 스트리밍 패턴 (핵심)
```python
from sse_starlette.sse import EventSourceResponse

@app.post("/api/v1/chat/stream")
async def chat_stream(request: ChatRequest):
    async def generate():
        async for chunk in llm_client.stream(
            messages=build_prompt(request),
            model=request.model
        ):
            yield {"data": json.dumps({"token": chunk})}
        yield {"data": json.dumps({"done": True})}
    
    return EventSourceResponse(generate())
```

---

## 3. 애니메이션 AI 이미지 생성 API

| 서비스 | 품질 | API | 가격 | 특징 |
|--------|------|-----|------|------|
| **NovelAI Diffusion V4.5** | ⭐⭐⭐⭐⭐ | REST API 있음 | 구독제 ($10-25/mo) | 애니 최강. Danbooru 태그 기반. V4.5 최신 |
| **Stable Diffusion XL + LoRA** | ⭐⭐⭐⭐ | 자체 호스팅 / Replicate | GPU 비용 | 오픈소스. Animagine XL 등 애니 특화 모델 |
| **Stability AI API** | ⭐⭐⭐⭐ | REST API | $0.002-0.04/이미지 | SD3 공식 API. 애니 스타일 가능 |
| **Waifu Diffusion** | ⭐⭐⭐ | 자체 호스팅 | 무료(오픈소스) | MIT 라이선스. 커뮤니티 빌드 |
| **Replicate** | ⭐⭐⭐⭐ | REST API | 사용량 기반 | 다양한 애니 모델 호스팅. 간편한 API |
| **Runpod Serverless** | ⭐⭐⭐⭐ | REST API | GPU 시간당 | ComfyUI 워크플로우 서버리스 실행 |

**추천 전략**:
- **MVP/초기**: Replicate API + Animagine XL 또는 NovelAI API
- **스케일업**: RunPod Serverless + ComfyUI + 커스텀 LoRA
- **최고 품질**: NovelAI V4.5 API (애니 특화 최강)

---

## 4. 인프라

### 개발 환경
- **컨테이너**: Docker Compose (FastAPI + PostgreSQL + Redis)
- **CI/CD**: GitHub Actions
- **모니터링**: Sentry (에러), Prometheus + Grafana (메트릭)

### 프로덕션
- **서버**: AWS ECS Fargate / GCP Cloud Run
- **DB**: RDS PostgreSQL / Cloud SQL
- **CDN**: CloudFront / Cloud CDN (캐릭터 이미지)
- **로드밸런서**: ALB (SSE 스트리밍 지원 확인 필수)
