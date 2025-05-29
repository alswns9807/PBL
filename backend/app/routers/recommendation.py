from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.recommendation import RecommendedBook
from app.services.recommendation_service import unified_recommendation

router = APIRouter(
    prefix="/recommendations",
    tags=["Recommendation"]
)

@router.get("/", response_model=list[RecommendedBook])
def recommend_books(user_id: str = Query(...), db: Session = Depends(get_db)):
    """
    AI 기반 + 장르 기반 통합 추천 결과 제공 (최대 10개)
    """
    recommendations = unified_recommendation(user_id, db)
    if not recommendations:
        raise HTTPException(status_code=404, detail="추천할 책이 없습니다.")
    return recommendations
