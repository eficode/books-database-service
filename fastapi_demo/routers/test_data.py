from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from ..database import get_db
from ..models import TestData, TestDataInfo
from typing import List

router = APIRouter()

@router.get("/test-data/outdated", response_model=List[TestDataInfo])
def get_outdated_test_data(db: Session = Depends(get_db)):
    threshold_date = datetime.now() - timedelta(days=30)
    outdated_data = db.query(TestData).filter(TestData.created_at < threshold_date).all()
    if not outdated_data:
        raise HTTPException(status_code=400, detail="Incomplete test data")
    return [TestDataInfo(**data.__dict__) for data in outdated_data]

@router.delete("/test-data/outdated")
def delete_outdated_test_data(db: Session = Depends(get_db)):
    threshold_date = datetime.now() - timedelta(days=30)
    outdated_data = db.query(TestData).filter(TestData.created_at < threshold_date).all()
    if not outdated_data:
        raise HTTPException(status_code=400, detail="No outdated test data found")
    try:
        for data in outdated_data:
            db.delete(data)
        db.commit()
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to remove outdated test data")
    return {"detail": "Outdated test data removed"}