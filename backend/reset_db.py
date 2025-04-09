# reset_db.py

from app.database import engine
from app.models import user, book, genre, reading_records, note
from app.models.user import Base as UserBase
from app.models.book import Base as BookBase
from app.models.reading_records import Base as ReadingRecordBase
from app.models.note import Base as NoteBase

print("🔁 모든 테이블 삭제 중...")
BookBase.metadata.drop_all(bind=engine)

print("🧱 모든 테이블 재생성 중...")
BookBase.metadata.create_all(bind=engine)

print("✅ 초기화 완료")
