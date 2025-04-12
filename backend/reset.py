# reset.py
from app.database import engine
from sqlalchemy import text

# 직접 DROP CASCADE 명령 수행 (순서 무시하고 한방에 날려버림)
with engine.connect() as conn:
    print("⚠️ 모든 테이블 DROP CASCADE 실행 중...")
    conn.execute(text("DROP SCHEMA public CASCADE;"))
    conn.execute(text("CREATE SCHEMA public;"))
    print("✅ 모든 테이블 및 제약 조건 제거 완료")

# 이후 테이블 다시 생성
from app.models.user import Base as UserBase
from app.models.book import Base as BookBase
from app.models.genre import Base as GenreBase
from app.models.reading_records import Base as RecordBase
from app.models.note import Base as NoteBase
from app.models.friend import Base as FriendBase

print("🧱 테이블 재생성 중...")
UserBase.metadata.create_all(bind=engine)
BookBase.metadata.create_all(bind=engine)
GenreBase.metadata.create_all(bind=engine)
RecordBase.metadata.create_all(bind=engine)
NoteBase.metadata.create_all(bind=engine)
FriendBase.metadata.create_all(bind=engine)

print("🚀 초기화 완료")
