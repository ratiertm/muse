# Phase 6: 배포 & 폴리싱

**Goal:** 실사용 가능한 완성도 — 딸이 매일 쓴다  
**Success Criteria:** MB + 딸이 APK 설치하고 실제로 사용 가능

---

## Plan 01: 배포 스크립트 & 서버 설정 (Backend)

### 1.1 Production Docker Compose
**File:** `backend/docker-compose.prod.yml`

Services:
- PostgreSQL 16 (persistent volume, health check)
- FastAPI (gunicorn + uvicorn workers, auto-restart)
- Nginx (reverse proxy, SSL support)

Environment:
- Production database credentials
- API keys loaded from .env.production
- Proper resource limits

### 1.2 Nginx Configuration
**File:** `backend/nginx/default.conf`

Features:
- Reverse proxy to FastAPI (port 8000)
- SSL/TLS support (Let's Encrypt or self-signed)
- Request size limits (for file uploads)
- CORS headers
- Health check endpoint
- Rate limiting

### 1.3 Production Environment Template
**File:** `backend/.env.production.example`

Required vars:
- `DATABASE_URL` (PostgreSQL production)
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `JWT_SECRET` (secure random)
- `CORS_ORIGINS` (mobile app domain)
- `DEBUG=False`

### 1.4 Deployment Script
**File:** `backend/deploy.sh`

Steps:
1. Pull latest code from git
2. Build docker images
3. Run database migrations (alembic upgrade head)
4. Restart services with zero-downtime
5. Health check verification

### 1.5 Systemd Service (Optional Alternative)
**File:** `backend/charbot-backend.service`

For running without Docker on Oracle Cloud

### 1.6 Deployment README
**File:** `backend/DEPLOY.md`

Instructions for:
- Oracle Cloud 춘천 setup
- Domain/DNS configuration
- SSL certificate generation
- First-time deployment
- Updates and rollbacks
- Troubleshooting

---

## Plan 02: Flutter APK 빌드 설정

### 2.1 Environment-based Configuration
**Update:** `frontend/lib/core/constants/app_constants.dart`

Add build flavor support:
```dart
static String get baseUrl {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  switch (env) {
    case 'prod':
      return 'https://api.muse.your-domain.com'; // Production
    case 'staging':
      return 'http://your-oracle-ip:8000'; // Staging
    default:
      return 'http://10.0.2.2:8000'; // Dev (emulator)
  }
}
```

### 2.2 App Icon
**Setup:** `flutter_launcher_icons`

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.2

flutter_launcher_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A1A1A"
  adaptive_icon_foreground: "assets/icon/app_icon_fg.png"
```

Create simple Muse logo (placeholder: M letter on dark background)

### 2.3 Splash Screen
**Setup:** Native splash screen

Use Flutter's default or add `flutter_native_splash` package

### 2.4 Android Signing Configuration
**File:** `frontend/android/key.properties` (gitignored)

For release builds:
- Generate debug keystore for personal use
- Configure signing in `android/app/build.gradle`

### 2.5 Build Script
**File:** `frontend/build_apk.sh`

```bash
#!/bin/bash
flutter clean
flutter pub get
flutter build apk --release --dart-define=ENV=prod
echo "APK built: build/app/outputs/flutter-apk/app-release.apk"
```

### 2.6 Install README
**File:** `frontend/INSTALL.md`

Instructions:
- Enable "Install from Unknown Sources"
- Transfer APK to phone
- Install and grant permissions
- Configure server URL (if needed)

---

## Plan 03: 에러 처리 & UX 폴리싱 (Frontend)

### 3.1 Global Error Handler
**Update:** `lib/core/api/api_client.dart`

Add comprehensive error interceptor:
- Network errors → "서버에 연결할 수 없습니다"
- 401 → "로그인이 만료되었습니다"
- 403 → "권한이 없습니다"
- 404 → "요청한 데이터를 찾을 수 없습니다"
- 500 → "서버 오류가 발생했습니다"
- Timeout → "요청 시간이 초과되었습니다"

All in Korean, user-friendly

### 3.2 Network Error Screen
**New:** `lib/presentation/screens/error/network_error_screen.dart`

Show when backend unreachable:
- Friendly message
- "재시도" button
- "서버 설정" button (to change URL)

### 3.3 Loading States
**Update:** All list screens

Add shimmer/skeleton placeholders:
- Character list
- Scenario list
- Conversation history
- Chat messages

Use `shimmer` package

### 3.4 Empty States
**Update:** All list screens

Add empty state widgets:
- "캐릭터가 없습니다. 새로 만들어보세요!" (with icon)
- "시나리오가 없습니다."
- "대화 내역이 없습니다."

### 3.5 Pull-to-Refresh
**Update:** All list screens

Add `RefreshIndicator` wrapper:
- Character list
- Scenario list
- Conversation list

### 3.6 Snackbar Notifications
**Add:** Success/failure feedback

Global snackbar helper:
- Character created ✓
- Character deleted ✓
- Avatar generated ✓
- Network error ✗
- API error ✗

### 3.7 Chat Input Improvements
**Update:** `lib/presentation/screens/chat/chat_screen.dart`

Enhancements:
- Auto-focus text field when opening chat
- Disable send button while streaming
- Clear input after send
- Show typing indicator while waiting

### 3.8 Character Detail/Edit Screen
**New:** `lib/presentation/screens/character_detail/character_detail_screen.dart`

Features:
- Tap character card → view full details
- Edit button → switch to edit mode
- Save changes
- Delete character (with confirmation)
- View all conversations with this character

### 3.9 Confirmation Dialogs
**Add:** Before destructive actions

- Delete character: "정말 삭제하시겠습니까?"
- Delete conversation: "대화 내역이 삭제됩니다"
- Cancel/확인 buttons

### 3.10 Settings Screen
**New:** `lib/presentation/screens/settings/settings_screen.dart`

Features:
- **테마 전환:** 다크/라이트/시스템 (use Riverpod + SharedPreferences)
- **서버 URL:** TextField to change API endpoint
- **로그아웃:** Clear auth token and return to profile selection
- **앱 정보:**
  - 버전: 1.0.0
  - 제작: Muse Team
  - 라이선스

Add to navigation drawer

---

## Plan 04: 백엔드 안정성

### 4.1 Rate Limiting
**Add:** `slowapi` package

```python
# pyproject.toml
slowapi = "^0.1.9"
```

**Update:** `app/main.py`

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
```

Apply limits:
- `/api/v1/chat`: 60/minute per user
- `/api/v1/characters`: 30/minute per user
- `/api/v1/characters/auto-generate`: 5/minute per user (expensive)
- `/api/v1/characters/{id}/generate-avatar`: 3/minute per user (expensive)

### 4.2 Request Validation
**Review:** All endpoint schemas

Ensure proper validation:
- String length limits
- Required fields
- Type checking
- Enum validation

### 4.3 Consistent Error Responses
**Add:** `app/core/exceptions.py`

Standard error format:
```json
{
  "detail": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "fields": {"name": "Name is required"}
  }
}
```

Error codes:
- `VALIDATION_ERROR`
- `NOT_FOUND`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `RATE_LIMIT_EXCEEDED`
- `LLM_ERROR`
- `DATABASE_ERROR`

### 4.4 Structured Logging
**Update:** `app/main.py`

Add logging middleware:
```python
import logging
from pythonjsonlogger import jsonlogger

logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    fmt='%(asctime)s %(levelname)s %(name)s %(message)s'
)
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
```

Log:
- Request start/end
- Response time
- Error traces
- User ID (for debugging)
- LLM call metrics (tokens, latency)

### 4.5 Health Check Improvements
**Update:** `/health` endpoint

Check:
- Database connectivity (`SELECT 1`)
- OpenAI API key valid (optional ping)
- Anthropic API key valid (optional ping)
- Disk space
- Memory usage

Return detailed status:
```json
{
  "status": "ok",
  "service": "charbot-backend",
  "version": "0.1.0",
  "checks": {
    "database": "ok",
    "openai": "ok",
    "anthropic": "ok"
  }
}
```

### 4.6 CORS Configuration for Production
**Update:** `app/config.py`

Add mobile app to CORS origins:
```python
CORS_ORIGINS: list[str] = [
    "http://localhost:3000",
    "http://localhost:5173",
    "muse://app",  # Mobile app deep link
    "*",  # Allow all for now (personal use)
]
```

---

## Implementation Checklist

### Backend
- [ ] docker-compose.prod.yml
- [ ] nginx/default.conf
- [ ] .env.production.example
- [ ] deploy.sh (executable)
- [ ] charbot-backend.service (systemd)
- [ ] DEPLOY.md
- [ ] slowapi rate limiting
- [ ] app/core/exceptions.py
- [ ] Structured logging
- [ ] Enhanced health check
- [ ] CORS update

### Frontend
- [ ] Environment-based baseUrl
- [ ] flutter_launcher_icons setup
- [ ] assets/icon/app_icon.png
- [ ] Splash screen
- [ ] Android signing config
- [ ] build_apk.sh
- [ ] INSTALL.md
- [ ] Global error handler (Korean messages)
- [ ] Network error screen
- [ ] Loading states (shimmer)
- [ ] Empty states
- [ ] Pull-to-refresh
- [ ] Snackbar helper
- [ ] Chat input improvements
- [ ] Character detail/edit screen
- [ ] Confirmation dialogs
- [ ] Settings screen (theme/URL/logout/about)
- [ ] Add settings to drawer

---

## Testing Plan

### Backend Verification
```bash
cd backend
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 &
sleep 2
curl -s http://localhost:8000/health | jq
curl -s http://localhost:8000/api/v1/characters -H "Authorization: Bearer <token>"
kill %1
```

### Frontend Verification
```bash
cd frontend
flutter analyze
flutter test
flutter build apk --release --dart-define=ENV=prod
```

### Integration Test
1. Deploy backend to Oracle Cloud
2. Update frontend ENV to production URL
3. Build APK
4. Install on Android device
5. Test all flows:
   - Profile selection + PIN
   - Character create/edit/delete
   - 1:1 chat
   - Group chat
   - Avatar generation
   - Auto-generation
   - Scenario management
   - Settings (theme switch, logout)

---

## Success Criteria
- ✅ Backend runs on Oracle Cloud 춘천 with PostgreSQL
- ✅ APK builds without errors
- ✅ App installs and runs on MB + 딸's phones
- ✅ All features work end-to-end
- ✅ No crashes or major bugs
- ✅ Korean error messages are friendly
- ✅ Loading/empty states look good
- ✅ Settings screen functional
- ✅ 딸 actually uses it daily

---

## Next Steps After Phase 6
- Monitor usage and collect feedback
- Fix any bugs discovered in production
- Add requested features:
  - Voice messages?
  - Image sharing in chat?
  - Character sharing/export?
- Performance optimization if needed
- iOS build (if requested)
