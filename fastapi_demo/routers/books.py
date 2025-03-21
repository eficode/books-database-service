from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import AcademicLiterature
from fastapi_demo.dtos import AcademicLiteratureInfo

router = APIRouter()

@router.get("/books/{book_id}/related-academic-literature", response_model=List[AcademicLiteratureInfo])
def get_related_academic_literature(book_id: int, db: Session = Depends(get_db)):
    try:
        related_literature = db.query(AcademicLiterature).filter(
            AcademicLiterature.related_book_id == book_id,
            AcademicLiterature.publication_year < 1980
        ).all()
        if not related_literature:
            raise HTTPException(status_code=404, detail="No related academic literature found")
        for lit in related_literature:
            if not lit.title or not lit.author or not lit.publication_year:
                raise HTTPException(status_code=400, detail="Incomplete data for related academic literature")
        return [AcademicLiteratureInfo(**lit.__dict__) for lit in related_literature]
    except Exception as e:
        raise HTTPException(status_code=500, detail="System error while retrieving related academic literature")