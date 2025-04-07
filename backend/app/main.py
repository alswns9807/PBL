from fastapi import FastAPI
from app.database import engine
from app.models import user, book, reading_records, note  #테이블 생성됨
from app.routers import user as user_router 
from app.routers import books as books_router
from app.routers import reading_records as reading_router
from app.routers import note as note_router
from app.routers import statistics as statistics_router
from app.routers import books as books_router

app = FastAPI()

# 모델 기반 테이블 자동 생성
user.Base.metadata.create_all(bind=engine)
book.Base.metadata.create_all(bind=engine)
reading_records.Base.metadata.create_all(bind=engine)
note.Base.metadata.create_all(bind=engine)

# 라우터 등록
app.include_router(user_router.router)
app.include_router(reading_router.router)
app.include_router(note_router.router)
app.include_router(statistics_router.router)
app.include_router(books_router.router, prefix="/books", tags=["Books"])

@app.get("/")
def read_root():
    return {"message": "BookMate 백엔드"}

