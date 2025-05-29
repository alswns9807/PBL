# reset.py
from sqlalchemy import text
from app.database import engine
from app import models  # 🔥 모든 모델이 metadata에 등록되도록 반드시 import
from app.database import Base

# 스키마 전체 제거
with engine.connect() as conn:
    print("🧨 DROP SCHEMA public CASCADE...")
    conn.execute(text("DROP SCHEMA public CASCADE;"))
    conn.execute(text("CREATE SCHEMA public;"))

# 테이블 재생성
print("🧱 Creating tables...")
Base.metadata.create_all(bind=engine)
print("✅ Reset complete.")
