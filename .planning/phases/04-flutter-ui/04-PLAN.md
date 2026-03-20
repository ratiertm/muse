# Phase 4: Flutter 앱 기본 UI — 상세 계획

## 목표
**안드로이드 앱에서 캐릭터 생성하고 채팅할 수 있다**

**Success Criteria:**
- APK 설치 후 프로필 선택
- 캐릭터 목록 조회/생성
- 1:1 채팅 with SSE 스트리밍
- 깔끔한 다크/라이트 테마

---

## Wave 1: 프로젝트 셋업 + 인증

### Plan 01: Flutter 프로젝트 초기화
**파일:** 프로젝트 루트 구조

**작업:**
1. Flutter 프로젝트 생성
   ```bash
   cd /home/ratier/.openclaw/workspace/charbot
   flutter create --org kr.muse --project-name muse frontend
   ```

2. 필수 패키지 추가 (pubspec.yaml)
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     
     # State Management
     flutter_riverpod: ^3.0.0
     riverpod_annotation: ^3.0.0
     
     # Network
     dio: ^5.7.0
     
     # SSE Streaming
     http: ^1.2.0  # For SSE
     
     # Routing
     go_router: ^14.6.2
     
     # Storage
     shared_preferences: ^2.3.4
     
     # UI Components
     cached_network_image: ^3.4.1
     flutter_markdown: ^0.7.4+1
     
     # Utilities
     freezed_annotation: ^2.4.4
     json_annotation: ^4.9.0
     
   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^5.0.0
     
     # Code Generation
     build_runner: ^2.4.13
     riverpod_generator: ^3.0.0
     freezed: ^2.5.7
     json_serializable: ^6.8.0
   ```

3. 프로젝트 구조 생성
   ```
   lib/
   ├── main.dart
   ├── app.dart
   ├── core/
   │   ├── api/
   │   │   ├── api_client.dart
   │   │   ├── api_endpoints.dart
   │   │   └── sse_client.dart
   │   ├── theme/
   │   │   ├── app_theme.dart
   │   │   └── app_colors.dart
   │   ├── router/
   │   │   └── app_router.dart
   │   └── constants/
   │       └── app_constants.dart
   ├── data/
   │   ├── models/
   │   │   ├── user.dart
   │   │   ├── character.dart
   │   │   ├── conversation.dart
   │   │   └── message.dart
   │   ├── repositories/
   │   │   ├── user_repository.dart
   │   │   ├── character_repository.dart
   │   │   └── chat_repository.dart
   │   └── providers/
   │       ├── auth_provider.dart
   │       ├── character_provider.dart
   │       └── chat_provider.dart
   ├── presentation/
   │   ├── screens/
   │   │   ├── profile_selection/
   │   │   ├── pin_auth/
   │   │   ├── character_list/
   │   │   ├── character_create/
   │   │   ├── chat/
   │   │   └── conversation_list/
   │   └── widgets/
   │       ├── character_card.dart
   │       ├── message_bubble.dart
   │       └── typing_indicator.dart
   └── utils/
       ├── logger.dart
       └── extensions.dart
   ```

**완료 조건:**
- `flutter pub get` 성공
- 프로젝트 구조 생성됨

---

### Plan 02: 테마 + API 클라이언트 셋업

**파일:**
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/api/api_client.dart`
- `lib/core/api/api_endpoints.dart`
- `lib/core/api/sse_client.dart`
- `lib/core/constants/app_constants.dart`

**작업:**

1. **테마 설정 (Material 3)**
   - 다크/라이트 ColorScheme
   - 미니멀 디자인
   - 메시지 버블 스타일 정의

2. **API 클라이언트**
   - Dio 인스턴스 (base URL, interceptors)
   - JWT 토큰 자동 헤더 추가
   - 에러 핸들링

3. **SSE 클라이언트**
   - HTTP SSE 스트림 수신
   - `data: [DONE]` 처리

4. **API 엔드포인트 상수**
   ```dart
   class ApiEndpoints {
     static const users = '/api/v1/users';
     static const login = '/api/v1/auth/login';
     static const characters = '/api/v1/characters';
     static const chat = '/api/v1/chat';
     static const conversations = '/api/v1/conversations';
   }
   ```

**완료 조건:**
- 테마 전환 가능
- API 클라이언트 초기화 성공

---

### Plan 03: 데이터 모델

**파일:**
- `lib/data/models/user.dart`
- `lib/data/models/character.dart`
- `lib/data/models/conversation.dart`
- `lib/data/models/message.dart`

**작업:**
- Freezed + JSON Serializable로 모델 정의
- 백엔드 스키마와 매칭
- `build_runner` 실행

**모델 예시:**
```dart
@freezed
class Character with _$Character {
  const factory Character({
    required String id,
    required String name,
    required String personality,
    required String speechStyle,
    required String backstory,
    String? scenario,
    String? firstMessage,
    String? exampleDialogue,
    List<String>? tags,
    String? avatarUrl,
    String? modelPreference,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}
```

**완료 조건:**
- 모든 모델 생성
- JSON 직렬화 작동

---

### Plan 04: 프로필 선택 화면

**파일:**
- `lib/presentation/screens/profile_selection/profile_selection_screen.dart`
- `lib/data/providers/auth_provider.dart`

**UI 구성:**
```
┌────────────────────────────┐
│         Muse              │
│                            │
│   ┌──────────────────┐    │
│   │   👤 MB          │    │
│   │   아빠            │    │
│   └──────────────────┘    │
│                            │
│   ┌──────────────────┐    │
│   │   👧 딸           │    │
│   │   대학생          │    │
│   └──────────────────┘    │
│                            │
│   + 새 프로필 만들기      │
└────────────────────────────┘
```

**작업:**
1. 하드코딩 프로필 (MB, 딸)
2. 프로필 선택 → PIN 화면 이동
3. SharedPreferences에 선택된 프로필 저장

**완료 조건:**
- 프로필 선택 가능
- PIN 화면으로 전환

---

### Plan 05: PIN 인증 화면

**파일:**
- `lib/presentation/screens/pin_auth/pin_auth_screen.dart`
- `lib/data/repositories/user_repository.dart`

**UI 구성:**
```
┌────────────────────────────┐
│      👤 MB               │
│                            │
│   PIN 번호를 입력하세요    │
│                            │
│   ┌──┐ ┌──┐ ┌──┐ ┌──┐    │
│   │ ● │ │ ● │ │   │ │   │    │
│   └──┘ └──┘ └──┘ └──┘    │
│                            │
│   ┌───┬───┬───┐           │
│   │ 1 │ 2 │ 3 │           │
│   ├───┼───┼───┤           │
│   │ 4 │ 5 │ 6 │           │
│   ├───┼───┼───┤           │
│   │ 7 │ 8 │ 9 │           │
│   ├───┼───┼───┤           │
│   │   │ 0 │ ⌫ │           │
│   └───┴───┴───┘           │
└────────────────────────────┘
```

**작업:**
1. 숫자 키패드 (0-9 + 백스페이스)
2. PIN 입력 (4자리)
3. API 호출: `POST /api/v1/auth/login`
4. JWT 토큰 저장 (SharedPreferences)
5. 자동 로그인 (토큰 유효성 검사)

**완료 조건:**
- PIN 인증 성공 → 캐릭터 목록 화면
- 토큰 저장 확인

---

## Wave 2: 캐릭터 관리

### Plan 06: 캐릭터 목록 화면

**파일:**
- `lib/presentation/screens/character_list/character_list_screen.dart`
- `lib/presentation/widgets/character_card.dart`
- `lib/data/repositories/character_repository.dart`
- `lib/data/providers/character_provider.dart`

**UI 구성:**
```
┌────────────────────────────┐
│ ← 로그아웃    내 캐릭터  ⚙️│
├────────────────────────────┤
│                            │
│  ┌────────┐  ┌────────┐   │
│  │ 아바타  │  │ 아바타  │   │
│  │ 세라피나│  │ 디오    │   │
│  │ #판타지 │  │ #죠죠   │   │
│  └────────┘  └────────┘   │
│                            │
│  ┌────────┐  ┌────────┐   │
│  │ 아바타  │  │   +     │   │
│  │ 홈즈    │  │ 새캐릭터│   │
│  │ #추리   │  │         │   │
│  └────────┘  └────────┘   │
│                            │
└────────────────────────────┘
```

**작업:**
1. `GET /api/v1/characters` 호출
2. GridView로 캐릭터 카드 표시
3. 캐릭터 클릭 → 채팅 화면
4. FAB (+) → 캐릭터 생성 화면

**Riverpod Provider:**
```dart
@riverpod
Future<List<Character>> characterList(CharacterListRef ref) async {
  final repo = ref.watch(characterRepositoryProvider);
  return await repo.getCharacters();
}
```

**완료 조건:**
- 캐릭터 목록 표시
- 로딩/에러 상태 처리

---

### Plan 07: 캐릭터 생성 화면

**파일:**
- `lib/presentation/screens/character_create/character_create_screen.dart`

**UI 구성 (스크롤 가능 폼):**
```
┌────────────────────────────┐
│ ← 뒤로    새 캐릭터     [저장]│
├────────────────────────────┤
│                            │
│  [ 아바타 ] (클릭하여 선택) │
│                            │
│  이름 *                    │
│  ┌────────────────────┐   │
│  │ 세라피나            │   │
│  └────────────────────┘   │
│                            │
│  성격 *                    │
│  ┌────────────────────┐   │
│  │ 상냥하고 호기심 많음 │   │
│  └────────────────────┘   │
│                            │
│  말투 *                    │
│  ┌────────────────────┐   │
│  │ 따뜻하고 부드러움    │   │
│  └────────────────────┘   │
│                            │
│  배경 스토리 *             │
│  ┌────────────────────┐   │
│  │ 숲의 수호자...      │   │
│  └────────────────────┘   │
│                            │
│  시나리오 (선택)           │
│  첫 메시지 (선택)          │
│  예시 대화 (선택)          │
│                            │
│  태그                      │
│  # 판타지 # 힐링           │
│                            │
└────────────────────────────┘
```

**작업:**
1. Form 위젯 (필수 입력 검증)
2. `POST /api/v1/characters` 호출
3. 생성 성공 → 캐릭터 목록으로 복귀
4. 태그 입력 (Chips)

**완료 조건:**
- 캐릭터 생성 성공
- 유효성 검증 작동

---

## Wave 3: 채팅 기능

### Plan 08: 채팅 화면 (1:1)

**파일:**
- `lib/presentation/screens/chat/chat_screen.dart`
- `lib/presentation/widgets/message_bubble.dart`
- `lib/presentation/widgets/typing_indicator.dart`
- `lib/data/repositories/chat_repository.dart`
- `lib/data/providers/chat_provider.dart`

**UI 구성:**
```
┌────────────────────────────┐
│ ← 뒤로   👤 세라피나    ⚙️│
├────────────────────────────┤
│                            │
│ [👤]  *부드러운 빛이...     │
│      "제 집이에요"          │
│                            │
│                  안녕? [나]│
│                            │
│ [👤]  타이핑 중...          │
│      ███████▋              │
│                            │
├────────────────────────────┤
│ [📷] 메시지 입력...    [➤] │
└────────────────────────────┘
```

**작업:**

1. **메시지 리스트**
   - `GET /api/v1/conversations/{id}/messages` 로드
   - ListView (reverse: true)
   - 마크다운 렌더링 (*행동*, "대사")

2. **SSE 스트리밍 수신**
   ```dart
   Stream<String> streamChat(String conversationId, String message) async* {
     final response = await dio.post(
       '/api/v1/chat',
       data: {
         'character_id': characterId,
         'conversation_id': conversationId,
         'message': message,
       },
       options: Options(
         responseType: ResponseType.stream,
       ),
     );
     
     final stream = response.data.stream;
     await for (var chunk in stream.transform(utf8.decoder)) {
       // Parse SSE
       if (chunk.startsWith('data: ')) {
         final data = chunk.substring(6);
         if (data == '[DONE]') break;
         yield data;
       }
     }
   }
   ```

3. **실시간 타이핑 효과**
   - StreamBuilder로 chunk 누적 표시
   - 완료 시 메시지 리스트에 추가

4. **메시지 입력**
   - TextField + IconButton
   - Enter 키 전송

**Riverpod Provider:**
```dart
@riverpod
class ChatController extends _$ChatController {
  List<Message> _messages = [];
  
  @override
  Future<List<Message>> build(String conversationId) async {
    return await ref.read(chatRepositoryProvider).getMessages(conversationId);
  }
  
  Future<void> sendMessage(String text) async {
    // Add user message
    _messages.add(Message(role: 'user', content: text));
    state = AsyncValue.data(_messages);
    
    // Stream AI response
    final stream = ref.read(chatRepositoryProvider).streamChat(conversationId, text);
    String assistantMessage = '';
    
    await for (final chunk in stream) {
      assistantMessage += chunk;
      // Update last message with streaming content
      state = AsyncValue.data([..._messages, Message(role: 'assistant', content: assistantMessage)]);
    }
    
    // Finalize
    _messages.add(Message(role: 'assistant', content: assistantMessage));
    state = AsyncValue.data(_messages);
  }
}
```

**완료 조건:**
- 메시지 송수신 작동
- SSE 스트리밍 실시간 표시
- 마크다운 렌더링

---

### Plan 09: 대화 목록 화면

**파일:**
- `lib/presentation/screens/conversation_list/conversation_list_screen.dart`

**UI 구성:**
```
┌────────────────────────────┐
│ ← 뒤로      대화 목록       │
├────────────────────────────┤
│                            │
│  [👤] 세라피나              │
│       "제 집이에요..."      │
│       2시간 전              │
│  ────────────────────────  │
│  [👤] 디오                  │
│       "무다무다!"           │
│       어제                  │
│  ────────────────────────  │
│  [👤] 홈즈                  │
│       "Elementary, my..."   │
│       3일 전                │
│                            │
└────────────────────────────┘
```

**작업:**
1. `GET /api/v1/conversations?character_id={id}` 호출
2. 대화 리스트 표시 (최근 메시지 미리보기)
3. 탭 → 채팅 화면 이어하기

**완료 조건:**
- 대화 목록 표시
- 기존 대화 이어하기 작동

---

### Plan 10: 라우팅 + 앱 초기화

**파일:**
- `lib/core/router/app_router.dart`
- `lib/app.dart`
- `lib/main.dart`

**작업:**

1. **GoRouter 설정**
   ```dart
   final router = GoRouter(
     initialLocation: '/profile-selection',
     routes: [
       GoRoute(
         path: '/profile-selection',
         builder: (context, state) => ProfileSelectionScreen(),
       ),
       GoRoute(
         path: '/pin-auth',
         builder: (context, state) => PinAuthScreen(),
       ),
       GoRoute(
         path: '/characters',
         builder: (context, state) => CharacterListScreen(),
       ),
       GoRoute(
         path: '/character/create',
         builder: (context, state) => CharacterCreateScreen(),
       ),
       GoRoute(
         path: '/chat/:characterId',
         builder: (context, state) => ChatScreen(
           characterId: state.pathParameters['characterId']!,
         ),
       ),
       GoRoute(
         path: '/conversations/:characterId',
         builder: (context, state) => ConversationListScreen(
           characterId: state.pathParameters['characterId']!,
         ),
       ),
     ],
   );
   ```

2. **자동 로그인 체크**
   - main()에서 토큰 확인
   - 유효하면 `/characters`로 라우팅
   - 없으면 `/profile-selection`

3. **ProviderScope 래핑**
   ```dart
   void main() {
     runApp(
       ProviderScope(
         child: MuseApp(),
       ),
     );
   }
   ```

**완료 조건:**
- 전체 네비게이션 작동
- 자동 로그인 작동

---

## 테스트 & 빌드

### Plan 11: Flutter Analyze + 테스트

**작업:**
1. `flutter pub get`
2. `flutter analyze` (경고 0개 목표)
3. Hot reload 테스트
4. API 연동 테스트 (백엔드 실행 필요)

**완료 조건:**
- analyze 통과
- 모든 화면 작동 확인

---

### Plan 12: APK 빌드 (선택)

**작업:**
```bash
cd /home/ratier/.openclaw/workspace/charbot/frontend
flutter build apk --release
```

**완료 조건:**
- APK 생성: `build/app/outputs/flutter-apk/app-release.apk`

---

## Implementation Checklist

- [ ] Plan 01: Flutter 프로젝트 초기화
- [ ] Plan 02: 테마 + API 클라이언트 셋업
- [ ] Plan 03: 데이터 모델
- [ ] Plan 04: 프로필 선택 화면
- [ ] Plan 05: PIN 인증 화면
- [ ] Plan 06: 캐릭터 목록 화면
- [ ] Plan 07: 캐릭터 생성 화면
- [ ] Plan 08: 채팅 화면 (1:1)
- [ ] Plan 09: 대화 목록 화면
- [ ] Plan 10: 라우팅 + 앱 초기화
- [ ] Plan 11: Flutter Analyze + 테스트
- [ ] Plan 12: APK 빌드 (선택)

---

## 완료 기준
✅ 프로필 선택 → PIN 인증 → 캐릭터 목록 → 캐릭터 생성 → 채팅  
✅ SSE 스트리밍 실시간 표시  
✅ 다크/라이트 테마  
✅ `flutter analyze` 통과  
✅ 실제 백엔드 API 연동 작동
