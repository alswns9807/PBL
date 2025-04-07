from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.note import Note
from app.schemas.note import NoteCreate, NoteOut, NoteBase

router = APIRouter(prefix="/notes", tags=["Notes"])

# DB 세션
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

#메모 등록
@router.post("/", response_model=NoteOut)
def create_note(note: NoteCreate, db: Session = Depends(get_db)):
    new_note = Note(**note.dict())
    db.add(new_note)
    db.commit()
    db.refresh(new_note)
    return new_note

#특정 독서 기록의 메모 조회
@router.get("/{user_book_id}", response_model=list[NoteOut])
def get_notes_by_user_book(user_book_id: int, db: Session = Depends(get_db)):
    return db.query(Note).filter(Note.user_book_id == user_book_id).all()

#메모 수정
@router.put("/{note_id}", response_model=NoteOut)
def update_note(note_id: int, updated: NoteBase, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.note_id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    note.content = updated.content
    db.commit()
    db.refresh(note)
    return note

#메모 삭제
@router.delete("/{note_id}")
def delete_note(note_id: int, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.note_id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    db.delete(note)
    db.commit()
    return {"message": "Note deleted"}
