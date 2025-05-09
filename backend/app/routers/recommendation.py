from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.services.recommendation_service import recommend_books_by_genre
from app.schemas.recommendation import RecommendedBook
from app.services.recommendation_ai_service import get_ai_recommendations

router = APIRouter(
    prefix="/recommendations",
    tags=["Recommendation"]
)

@router.get("/genre", response_model=list[RecommendedBook])
def recommend_by_genre(user_id: int = Query(...), db: Session = Depends(get_db)):
    """
    사용자의 가장 많이 읽은 장르를 기준으로,
    아직 읽지 않은 책 중 등록 수가 많은 책들을 추천합니다.
    """
    recommendations = recommend_books_by_genre(user_id, db)
    if not recommendations:
        raise HTTPException(status_code=404, detail="추천할 책이 없습니다.")
    return recommendations

@router.get("/ai", response_model=list[RecommendedBook])
def recommend_ai_books(user_id: int = Query(...), db: Session = Depends(get_db)):
    recommendations = get_ai_recommendations(db, user_id)
    if not recommendations:
        raise HTTPException(status_code=404, detail="추천할 책이 없습니다.")
    return recommendations

