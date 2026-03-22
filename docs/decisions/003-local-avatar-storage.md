# ADR-003: CDN URL 대신 로컬 아바타 저장

- **Status**: Accepted
- **Date**: 2026-03-21
- **Context**: MAL CDN URL이 만료되어 캐릭터 이미지가 깨짐. Jikan API로 정확한 이미지를 다운로드해야 함.
- **Decision**: `backend/static/avatars/{character_id}.jpg`에 로컬 저장. FastAPI StaticFiles로 서빙. 프론트에서 `AppConstants.resolveAvatarUrl()`로 상대경로→절대URL 변환.
- **Alternatives considered**:
  - CDN URL 직접 사용 → 만료 문제 재발
  - S3/R2 클라우드 스토리지 → 비용 발생, 오버엔지니어링
  - Base64 DB 저장 → DB 비대화, 쿼리 느려짐
- **Consequences**:
  - 이미지 로딩 안정적 (서버 로컬 파일)
  - 서버 디스크 사용 (~5MB for 60 캐릭터)
  - 서버 배포 시 avatars 폴더도 함께 rsync 필요
