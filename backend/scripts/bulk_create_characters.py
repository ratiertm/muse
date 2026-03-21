#!/usr/bin/env python3
"""
Bulk character creation CLI for Muse.

Usage:
  # 1) LLM 자동 생성 (작품명 + 캐릭터 목록)
  python scripts/bulk_create_characters.py --auto characters.yaml

  # 2) 완성된 JSON 파일로 직접 생성
  python scripts/bulk_create_characters.py --json characters.json

  # 3) 건조 실행 (DB 저장 없이 확인만)
  python scripts/bulk_create_characters.py --auto characters.yaml --dry-run

  # 4) 특정 유저에게 할당
  python scripts/bulk_create_characters.py --auto characters.yaml --user-id 00000000-...
"""
import argparse
import asyncio
import json
import sys
from pathlib import Path
from uuid import UUID

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.db.database import AsyncSessionLocal
from app.models.user import User
from app.models.character import Character
from app.core.auto_generator import auto_generator
from app.schemas.character import CharacterCreate
from sqlalchemy import select

# Default user for bulk creation
DEFAULT_USER_ID = UUID("00000000-0000-0000-0000-000000000001")


async def verify_user(db, user_id: UUID) -> User:
    """Verify user exists in DB."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        print(f"[ERROR] User {user_id} not found. Run seed_test_user.py first.")
        sys.exit(1)
    return user


async def create_character_in_db(db, user_id: UUID, data: CharacterCreate) -> Character:
    """Save a single character to DB."""
    character = Character(user_id=user_id, **data.model_dump())
    db.add(character)
    await db.flush()
    return character


async def bulk_auto_generate(yaml_path: str, user_id: UUID, dry_run: bool):
    """
    YAML 파일에서 작품명+캐릭터 목록을 읽고 LLM으로 자동 생성.

    YAML format:
      - source_work: "귀멸의 칼날"
        characters:
          - "탄지로"
          - "네즈코"
          - "젠이츠"
        is_public: true

      - source_work: "원피스"
        characters:
          - "루피"
          - "조로"
    """
    # Support both YAML and JSON input
    if yaml_path.endswith(".json"):
        with open(yaml_path, "r", encoding="utf-8") as f:
            entries = json.load(f)
    elif HAS_YAML:
        with open(yaml_path, "r", encoding="utf-8") as f:
            entries = yaml.safe_load(f)
    else:
        print("[ERROR] PyYAML not installed. Use JSON format or: pip install pyyaml")
        sys.exit(1)

    if not isinstance(entries, list):
        print("[ERROR] YAML must be a list of entries.")
        sys.exit(1)

    total = sum(len(e.get("characters", [])) for e in entries)
    print(f"=== Bulk Auto-Generate: {total} characters from {len(entries)} works ===\n")

    created = 0
    failed = 0

    async with AsyncSessionLocal() as db:
        if not dry_run:
            await verify_user(db, user_id)

        for entry in entries:
            source_work = entry["source_work"]
            is_public = entry.get("is_public", True)
            char_names = entry.get("characters", [])

            print(f"[{source_work}] {len(char_names)} characters")

            for name in char_names:
                try:
                    print(f"  Generating '{name}'...", end=" ", flush=True)
                    char_data = await auto_generator.generate_from_source(
                        source_work=source_work,
                        character_name=name,
                    )
                    char_data.is_public = is_public

                    if dry_run:
                        print(f"OK (dry-run)")
                        print(f"    name={char_data.name}, tags={char_data.tags}")
                    else:
                        character = await create_character_in_db(db, user_id, char_data)
                        print(f"OK (id={character.id})")

                    created += 1

                except Exception as e:
                    print(f"FAILED: {e}")
                    failed += 1

        if not dry_run:
            await db.commit()

    print(f"\n=== Done: {created} created, {failed} failed ===")


async def bulk_from_json(json_path: str, user_id: UUID, dry_run: bool):
    """
    JSON 파일에서 완성된 캐릭터 데이터를 읽고 DB에 저장.

    JSON format:
      [
        {
          "name": "탄지로",
          "personality": "착하고 성실한...",
          "speech_style": "~입니다 체를...",
          "backstory": "탄지로는...",
          "scenario": "",
          "first_message": "안녕하세요!",
          "example_dialogue": "",
          "tags": ["귀멸의 칼날", "주인공"],
          "is_public": true
        }
      ]
    """
    with open(json_path, "r", encoding="utf-8") as f:
        characters = json.load(f)

    if not isinstance(characters, list):
        print("[ERROR] JSON must be a list of character objects.")
        sys.exit(1)

    print(f"=== Bulk Create from JSON: {len(characters)} characters ===\n")

    created = 0
    failed = 0

    async with AsyncSessionLocal() as db:
        if not dry_run:
            await verify_user(db, user_id)

        for i, char_dict in enumerate(characters, 1):
            try:
                char_data = CharacterCreate(**char_dict)

                if dry_run:
                    print(f"  [{i}] {char_data.name} - OK (dry-run)")
                else:
                    character = await create_character_in_db(db, user_id, char_data)
                    print(f"  [{i}] {char_data.name} - OK (id={character.id})")

                created += 1

            except Exception as e:
                name = char_dict.get("name", f"entry {i}")
                print(f"  [{i}] {name} - FAILED: {e}")
                failed += 1

        if not dry_run:
            await db.commit()

    print(f"\n=== Done: {created} created, {failed} failed ===")


def main():
    parser = argparse.ArgumentParser(description="Muse - Bulk Character Creator")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--auto", metavar="YAML_FILE",
                       help="Auto-generate from YAML (source_work + character names)")
    group.add_argument("--json", metavar="JSON_FILE",
                       help="Create from pre-built JSON character data")

    parser.add_argument("--user-id", type=UUID, default=DEFAULT_USER_ID,
                        help=f"Owner user ID (default: {DEFAULT_USER_ID})")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview without saving to DB")

    args = parser.parse_args()

    if args.auto:
        asyncio.run(bulk_auto_generate(args.auto, args.user_id, args.dry_run))
    else:
        asyncio.run(bulk_from_json(args.json, args.user_id, args.dry_run))


if __name__ == "__main__":
    main()
