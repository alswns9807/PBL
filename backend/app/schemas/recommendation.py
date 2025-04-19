from pydantic import BaseModel
from typing import Optional

class RecommendedBook(BaseModel):
    isbn: str
    title: str
    author: str
    publisher: str
    cover_image: Optional[str] = None
    registered_count: int

    class Config:
        orm_mode = True