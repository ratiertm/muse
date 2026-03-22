# ADR-005: Oracle Cloud 1GB 서버 배포

- **Status**: Accepted
- **Date**: 2026-03-22
- **Context**: Oracle Cloud Free Tier ARM(4코어/24GB)을 생성할 수 없어서, 기존 x86_64 1GB 인스턴스에 배포.
- **Decision**: PostgreSQL + FastAPI를 1GB RAM에서 운영. swap 2GB 추가로 OOM 방지. Claude CLI는 서버에서 직접 실행.
- **Alternatives considered**:
  - ARM Free Tier 인스턴스 → 생성 불가 (리소스 부족)
  - PostgreSQL → SQLite 교체 → 이미 PostgreSQL 설치됨, 마이그레이션 비용
  - Fly.io / Railway → 월 $5+ 비용 발생
- **Consequences**:
  - 평상시 동작하나 동시 요청 시 느려질 수 있음
  - swap 사용으로 디스크 I/O 증가
  - Claude CLI 프로세스가 무겁기 때문에 동시 채팅 2개 이상은 위험
  - 가족 2명 사용에는 충분
