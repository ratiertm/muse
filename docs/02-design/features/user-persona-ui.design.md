# Design: 유저 페르소나 & 시나리오 참여 시스템

## 구현 순서

```
Step 1: 백엔드 — Conversation에 persona_id 추가
Step 2: 백엔드 — 그룹 채팅 API에 persona_id 연동
Step 3: 프론트 — Persona 모델/레포/프로바이더
Step 4: 프론트 — 페르소나 목록/편집 화면
Step 5: 프론트 — 그룹 채팅 만들기 화면에 페르소나 선택 추가
Step 6: 프론트 — 시나리오 대화 목록 (이어하기)
```

---

## Step 1: 백엔드 — Conversation 모델 수정

### 변경 파일: `backend/app/models/conversation.py`

```python
# 추가 컬럼
persona_id: Mapped[uuid.UUID | None] = mapped_column(
    GUID,
    ForeignKey("user_personas.id", ondelete="SET NULL"),
    nullable=True,
)

# 추가 관계
persona: Mapped["UserPersona | None"] = relationship("UserPersona")
```

### Alembic 마이그레이션
- `conversations` 테이블에 `persona_id` 컬럼 추가 (nullable, FK → user_personas.id)

### 변경 파일: `backend/app/schemas/chat.py`

```python
# GroupChatCreateRequest에 persona_id 추가
class GroupChatCreateRequest(BaseModel):
    scenario_id: UUID
    character_ids: list[UUID] = Field(..., min_length=2)
    title: str = Field(..., min_length=1, max_length=500)
    persona_id: UUID | None = Field(None, description="선택한 유저 페르소나")

# ConversationResponse에 persona_id 추가
class ConversationResponse(BaseModel):
    ...기존 필드...
    persona_id: UUID | None  # 추가
```

---

## Step 2: 백엔드 — 그룹 채팅에 페르소나 연동

### 변경 파일: `backend/app/api/v1/group_chat.py`

`create_group_chat`:
- `request.persona_id`를 conversation에 저장
- persona가 지정되면 해당 페르소나 정보를 로드

`send_group_message`:
- conversation의 `persona_id`로 페르소나 로드
- `PromptBuilder.build_prompt_with_briefing(..., persona=persona)`에 전달
- 현재는 default persona만 사용 → conversation에 저장된 persona 사용으로 변경

### 변경 파일: `backend/app/services/chat_service.py`

`create_group_conversation`:
- `persona_id` 파라미터 추가
- Conversation 생성 시 `persona_id` 설정

---

## Step 3: 프론트 — Persona 데이터 레이어

### 신규: `frontend/lib/data/models/persona.dart`

```dart
@freezed
class Persona with _$Persona {
  const factory Persona({
    required String id,
    required String userId,
    required String name,
    String? appearance,
    String? personality,
    String? description,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Persona;

  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json);
}

@freezed
class PersonaCreate with _$PersonaCreate {
  const factory PersonaCreate({
    required String name,
    String? appearance,
    String? personality,
    String? description,
    @Default(false) bool isDefault,
  }) = _PersonaCreate;

  factory PersonaCreate.fromJson(Map<String, dynamic> json) => _$PersonaCreateFromJson(json);
}
```

### 신규: `frontend/lib/data/repositories/persona_repository.dart`

```dart
class PersonaRepository {
  final ApiClient apiClient;

  Future<List<Persona>> getPersonas() async { ... }
  Future<Persona> createPersona(PersonaCreate data) async { ... }
  Future<Persona> updatePersona(String id, Map<String, dynamic> data) async { ... }
  Future<void> deletePersona(String id) async { ... }
}
```

### 신규: `frontend/lib/data/providers/persona_provider.dart`

```dart
final personaRepositoryProvider = Provider<PersonaRepository>((ref) { ... });
final personaListProvider = FutureProvider<List<Persona>>((ref) async { ... });
```

### 변경: `frontend/lib/core/api/api_endpoints.dart`

```dart
static const String personas = '/api/v1/personas';
static String persona(String id) => '$personas/$id';
```

---

## Step 4: 프론트 — 페르소나 관리 화면

### 신규: `frontend/lib/presentation/screens/persona_list/persona_list_screen.dart`

**UI 구성:**
- AppBar: "내 페르소나" + 추가 버튼(+)
- 리스트: 카드 형태 (이름, 성격 요약, 기본 페르소나 뱃지)
- 카드 탭 → 편집 화면
- 카드 길게 누르기 → 삭제 다이얼로그
- 빈 상태: "페르소나를 만들어 시나리오에 참여하세요"

### 신규: `frontend/lib/presentation/screens/persona_edit/persona_edit_screen.dart`

**UI 구성:**
- 생성/수정 공용 폼
- 필드: 이름(필수), 외모, 성격, 설명
- "기본 페르소나로 설정" 스위치
- 저장 버튼

### 변경: `frontend/lib/presentation/screens/settings/settings_screen.dart`

```dart
// "내 페르소나" 메뉴 추가 (테마 설정 위)
ListTile(
  leading: Icon(Icons.face),
  title: Text('내 페르소나'),
  subtitle: Text('시나리오에서 사용할 캐릭터'),
  onTap: () => context.push('/personas'),
),
```

### 변경: `frontend/lib/core/router/app_router.dart`

```dart
GoRoute(path: '/personas', builder: ... PersonaListScreen),
GoRoute(path: '/persona/create', builder: ... PersonaEditScreen),
GoRoute(path: '/persona/edit/:personaId', builder: ... PersonaEditScreen),
```

---

## Step 5: 프론트 — 그룹 채팅 만들기에 페르소나 선택

### 변경: `frontend/lib/presentation/screens/group_create/group_create_screen.dart`

**기존 순서:** 제목 → 시나리오 선택 → 캐릭터 선택
**변경 후:** 제목 → **내 페르소나 선택** → 시나리오 선택 → 캐릭터 선택

```dart
// 시나리오 선택 위에 페르소나 드롭다운 추가
final personasAsync = ref.watch(personaListProvider);

DropdownButtonFormField<Persona>(
  decoration: InputDecoration(labelText: '내 페르소나'),
  items: personas.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
  onChanged: (persona) => setState(() => _selectedPersona = persona),
  hint: Text('나는 누구로 참여할까?'),
),
```

**그룹 채팅 생성 시:**
```dart
repository.createGroupChat(
  scenarioId: _selectedScenario!.id,
  characterIds: _selectedCharacterIds,
  title: _titleController.text,
  personaId: _selectedPersona?.id,  // 추가
);
```

### 변경: `frontend/lib/data/repositories/group_chat_repository.dart`

- `createGroupChat`에 `personaId` 파라미터 추가

---

## Step 6: 프론트 — 시나리오 대화 목록 (이어하기)

### 변경: `frontend/lib/presentation/screens/scenario_list/scenario_list_screen.dart`

시나리오 카드 터치 시:
- 해당 시나리오의 **이전 대화 목록** 표시
- 각 대화: "[페르소나명] × [캐릭터1, 캐릭터2] — 마지막 대화 시간"
- 대화 터치 → 기존 그룹 채팅 화면으로 이동 (conversation_id 전달)
- "새 대화 시작" 버튼 → 그룹 채팅 만들기 화면

### 변경: `frontend/lib/data/models/conversation.dart`

```dart
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    ...기존 필드...
    String? personaId,  // 추가
  }) = _Conversation;
}
```

---

## 파일 변경 요약

| 구분 | 파일 | 작업 |
|------|------|------|
| BE 모델 | `models/conversation.py` | persona_id 컬럼 추가 |
| BE 스키마 | `schemas/chat.py` | GroupChatCreateRequest + ConversationResponse에 persona_id |
| BE API | `api/v1/group_chat.py` | persona_id 저장 + 채팅 시 persona 로드 |
| BE 서비스 | `services/chat_service.py` | create_group_conversation에 persona_id |
| BE 마이그레이션 | `alembic/versions/...` | persona_id 컬럼 추가 |
| FE 모델 | `models/persona.dart` (신규) | Persona freezed 모델 |
| FE 레포 | `repositories/persona_repository.dart` (신규) | CRUD |
| FE 프로바이더 | `providers/persona_provider.dart` (신규) | Riverpod |
| FE 화면 | `screens/persona_list/` (신규) | 목록 화면 |
| FE 화면 | `screens/persona_edit/` (신규) | 편집 화면 |
| FE 수정 | `screens/group_create/group_create_screen.dart` | 페르소나 선택 |
| FE 수정 | `screens/settings/settings_screen.dart` | 메뉴 추가 |
| FE 수정 | `screens/scenario_list/scenario_list_screen.dart` | 대화 목록 |
| FE 수정 | `core/router/app_router.dart` | 라우트 추가 |
| FE 수정 | `core/api/api_endpoints.dart` | 엔드포인트 추가 |
| FE 수정 | `data/models/conversation.dart` | persona_id 필드 |

---

## 검증 시나리오

1. **페르소나 CRUD**: 설정 → 내 페르소나 → "쿠조 죠타로" 생성 → 수정 → 기본 설정
2. **그룹 채팅 생성**: 그룹 만들기 → "쿠조 죠타로" 선택 → 전독시 시나리오 → 김독자+유중혁 선택 → 시작
3. **채팅**: 죠타로로서 김독자, 유중혁과 대화 → God Agent가 페르소나 인식
4. **이어하기**: 앱 종료 → 재시작 → 시나리오 화면 → 이전 대화 선택 → 이어서 대화
5. **다른 페르소나**: "학생 A" 페르소나로 같은 시나리오 새 대화 시작 → 다른 대화 스레드
