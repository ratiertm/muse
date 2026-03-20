# 아키텍처 리서치: LLM 프롬프트 체인 & 컨텍스트 관리

## 1. 프롬프트 구조 (Character Roleplay)

### 전체 프롬프트 조립 순서
```
┌─────────────────────────────────────────┐
│ 1. System Prompt (시스템 지시)            │  ← 항상 최상단
│    - 응답 형식, 규칙, 안전 가이드          │
├─────────────────────────────────────────┤
│ 2. Character Card (캐릭터 정의)           │  ← 영구 토큰
│    - 이름, 설명, 성격, 시나리오            │
├─────────────────────────────────────────┤
│ 3. User Persona (유저 정보)              │  ← 영구 토큰
│    - 유저 이름, 외모, 설정                │
├─────────────────────────────────────────┤
│ 4. World Info / Lorebook (조건부)         │  ← 키워드 매칭시만
│    - 세계관, 장소, 아이템 정보             │
├─────────────────────────────────────────┤
│ 5. Memory / Summary (장기 기억)           │  ← 동적
│    - 과거 대화 요약                       │
│    - 벡터 검색 결과 (관련 과거 에피소드)    │
├─────────────────────────────────────────┤
│ 6. Example Messages (예시 대화)           │  ← 공간 있을 때만
│    - 캐릭터 말투/스타일 예시               │
├─────────────────────────────────────────┤
│ 7. Chat History (최근 대화)               │  ← 가능한 많이
│    - 최근 N개 메시지                      │
├─────────────────────────────────────────┤
│ 8. Post-History Instructions (JB)        │  ← 마지막 지시
│    - "캐릭터로서 응답하세요" 리마인더       │
├─────────────────────────────────────────┤
│ 9. Response Prefill (응답 시작)           │  ← Claude에 효과적
│    - "세라피나: *" 등으로 응답 유도         │
└─────────────────────────────────────────┘
```

### 토큰 할당 예시 (4K 컨텍스트 기준)
| 구간 | 토큰 | 비율 |
|------|------|------|
| System + 캐릭터 카드 + 유저 | ~500 | 12% |
| 메모리/요약 | ~300 | 7% |
| World Info | ~200 | 5% |
| 예시 대화 | ~200 | 5% |
| **채팅 히스토리** | **~2,500** | **63%** |
| 응답 여유 | ~300 | 8% |

### 128K 컨텍스트 모델의 경우
- 채팅 히스토리에 대부분 할당 가능
- 그러나 **비용이 컨텍스트 길이에 비례** → 무조건 긴 게 좋은 건 아님
- 적절한 요약 + 최근 20-50개 메시지가 실용적

---

## 2. 시스템 프롬프트 설계

### 기본 시스템 프롬프트 템플릿
```
당신은 "{{char}}"라는 캐릭터를 연기하는 창의적인 롤플레이 파트너입니다.

## 응답 규칙
- *이탈릭*으로 행동, 표정, 감정, 환경 묘사
- "큰따옴표"로 대사
- {{user}}의 행동을 대신 결정하지 마세요
- 3-5문단 분량으로 응답
- {{char}}의 성격과 말투를 일관되게 유지

## 캐릭터 정보
이름: {{char}}
{{description}}

## 성격
{{personality}}

## 시나리오
{{scenario}}
```

### 캐릭터 성격/말투 정의 기법

#### 1. PLists + Ali:Chat (가장 효과적)
```
[{{char}}'s personality = "상냥함", "수줍음", "호기심", "보호적"]
[{{char}}'s speech = "~요 어미 사용", "가끔 말 끝에 '...후후' 붙임", "감탄사 자주 사용"]
[{{char}}'s appearance = "긴 은발", "황금빛 눈", "하얀 로브"]
```

#### 2. W++ 포맷
```
[character("세라피나")
{
  Species("엘프")
  Age("200세" + "외모 20대")
  Personality("상냥" + "수줍" + "호기심" + "보호적")
  Speech("정중한 존댓말" + "~요 어미" + "가끔 고어체 섞임")
  Likes("숲" + "동물" + "치유 마법" + "차")
  Dislikes("폭력" + "거짓말")
}]
```

#### 3. 자연어 서술 (가장 직관적)
```
세라피나는 200년을 살아온 엘프 치유사다. 외모는 20대 초반으로 보이며, 
긴 은발에 황금빛 눈동자를 가지고 있다. 평소 상냥하고 정중한 존댓말을 
사용하지만, 당황하면 말을 더듬는 버릇이 있다. "아, 저... 그게요..." 
같은 표현을 자주 쓴다.
```

**추천**: PLists + 자연어 하이브리드. 구조화된 속성은 PList로, 복잡한 배경은 자연어로.

---

## 3. 컨텍스트 윈도우 관리

### 전략 1: 슬라이딩 윈도우 (기본)
```python
def build_context(messages, max_tokens=4000):
    permanent = system_prompt + character_card  # ~500 토큰
    remaining = max_tokens - len(permanent) - 300  # 응답 여유
    
    recent = []
    token_count = 0
    for msg in reversed(messages):
        msg_tokens = count_tokens(msg)
        if token_count + msg_tokens > remaining:
            break
        recent.insert(0, msg)
        token_count += msg_tokens
    
    return permanent + recent
```

### 전략 2: 요약 + 슬라이딩 (권장)
```python
def build_context_with_summary(chat_id, messages, max_tokens=4000):
    permanent = system_prompt + character_card  # ~500
    
    # 오래된 메시지는 요약으로 압축
    if len(messages) > 30:
        old_messages = messages[:-20]
        summary = summarize(old_messages)  # LLM으로 요약
        save_summary(chat_id, summary)
    
    # 요약 + 최근 20개 메시지
    context = permanent + summary + messages[-20:]
    return trim_to_fit(context, max_tokens)
```

### 전략 3: RAG 기반 메모리 (고급)
```python
def build_context_with_rag(chat_id, user_message, messages, max_tokens=4000):
    permanent = system_prompt + character_card
    
    # 현재 메시지와 관련된 과거 기억 검색
    relevant_memories = vector_search(
        query=user_message,
        collection=f"chat_{chat_id}",
        top_k=5
    )
    
    memory_section = format_memories(relevant_memories)
    recent = messages[-15:]
    
    return permanent + memory_section + recent
```

### 요약 프롬프트 예시
```
다음 대화를 간결하게 요약하세요. 중요한 사건, 감정 변화, 
새로 알게 된 사실을 포함하세요. 3인칭으로 작성.

[대화 내용]

요약:
```

---

## 4. 메모리 시스템 설계

### 계층적 메모리 아키텍처
```
┌───────────────────────┐
│   즉시 메모리          │  현재 컨텍스트 윈도우의 최근 메시지
│   (Working Memory)     │  → 항상 포함
├───────────────────────┤
│   단기 메모리          │  현재 세션의 요약
│   (Short-term)         │  → 세션 내 자동 생성
├───────────────────────┤
│   장기 메모리          │  핵심 사실, 관계, 감정
│   (Long-term)          │  → 벡터 DB + 구조화 저장
├───────────────────────┤
│   캐릭터 지식          │  캐릭터 카드 + World Info
│   (Character KB)       │  → 영구, 키워드 트리거
└───────────────────────┘
```

### 장기 메모리 자동 추출 (SillyTavern CharMemory 방식)
```python
MEMORY_EXTRACTION_PROMPT = """
다음 대화에서 캐릭터가 기억해야 할 중요한 사실을 추출하세요.

카테고리:
- FACT: 유저에 대한 사실 (이름, 직업, 취미 등)
- EVENT: 중요한 사건 
- EMOTION: 감정적으로 중요한 순간
- RELATIONSHIP: 관계 변화

JSON 배열로 출력:
[{"type": "FACT", "content": "유저의 이름은 민수", "importance": 0.9}]
"""

async def extract_memories(recent_messages):
    response = await llm.generate(
        system=MEMORY_EXTRACTION_PROMPT,
        messages=recent_messages[-10:]
    )
    memories = json.loads(response)
    for mem in memories:
        await vector_db.upsert(
            text=mem["content"],
            metadata={"type": mem["type"], "importance": mem["importance"]}
        )
```

---

## 5. 제타/크랙/SillyTavern 메모리 비교

| 앱 | 메모리 방식 | 특징 |
|----|-----------|------|
| **제타** | 서버 측 관리, 대화 기록 열람 가능 | 자체 LLM 최적화. 메모리 상세 미공개 |
| **크랙** | Claude 기반, 서버 측 컨텍스트 관리 | 슈퍼챗에서 더 긴 컨텍스트 제공 |
| **Character.AI** | Memory Box (모바일), 서버 측 요약 | 유저가 직접 메모리 추가/삭제 가능 |
| **SillyTavern** | 3단계: 캐릭터 카드 + Lorebook + 벡터 DB | 가장 유연. CharMemory 확장으로 자동 추출 |

### SillyTavern 메모리 상세
1. **캐릭터 카드**: 영구 정보 (설명, 성격, 첫 메시지, 예시 대화)
2. **Lorebook/World Info**: 키워드 매칭으로 동적 주입. 예: "마법"이 언급되면 마법 체계 설명 삽입
3. **벡터 스토리지 (Data Bank)**: ChromaDB 기반. 과거 대화를 벡터화하여 유사도 검색
4. **Summary 확장**: 대화 자동 요약. Author's Note로 수동 메모 추가
5. **Presence 플러그인**: 그룹챗에서 각 캐릭터별 개별 메모리

---

## 6. 프롬프트 체인 (다단계 처리)

### 채팅 요청 처리 파이프라인
```
유저 메시지 수신
    │
    ▼
[1] 안전 필터 ─── 프롬프트 인젝션 검출
    │
    ▼
[2] World Info 스캔 ─── 키워드 매칭 → 관련 로어 추출
    │
    ▼
[3] 메모리 검색 ─── 벡터 DB에서 관련 기억 검색
    │
    ▼
[4] 컨텍스트 조립 ─── 프롬프트 빌더로 전체 프롬프트 구성
    │
    ▼
[5] LLM 호출 ─── SSE 스트리밍
    │
    ▼
[6] 후처리 ─── 응답 필터링, 포맷 정리
    │
    ▼
[7] 메모리 업데이트 ─── 비동기로 새 기억 추출/저장
    │
    ▼
클라이언트에 스트리밍 전송
```

### 요약 체인 (비동기)
- 매 20-30 메시지마다 백그라운드에서 요약 생성
- 저렴한 모델(GPT-4o-mini) 사용으로 비용 절감
- 요약 품질 = 캐릭터 일관성에 직결

---

## 7. 응답 품질 향상 팁

### 1. Response Prefill (Claude에서 효과적)
```python
# Claude API에서 assistant 메시지로 응답 시작 유도
messages.append({
    "role": "assistant", 
    "content": f"{character_name}: *"
})
```

### 2. 부정적 프롬프트 (하지 말 것)
```
절대로 하지 마세요:
- {{user}}의 말이나 행동을 대신 작성
- OOC(Out of Character) 발언
- "AI입니다" 등 메타 발언
- 이전 응답을 그대로 반복
```

### 3. 온도(Temperature) 조절
- **롤플레이**: 0.7-0.9 (창의적)
- **사실 기반 대화**: 0.3-0.5
- **재생성(Swipe)**: 매번 다른 시드 또는 약간 높은 온도
