from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os

# .env 파일 로딩
load_dotenv()

# 환경변수에서 DB 주소 가져오기
DATABASE_URL = os.getenv("DATABASE_URL")

# DB 연결 엔진 생성
engine = create_engine(DATABASE_URL)

# DB 세션 생성
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 모델 클래스들이 상속받을 Base 클래스
Base = declarative_base()
