from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.report_service import send_daily_report

router = APIRouter()

@router.post("/reports/daily-email", summary="Generate and send daily email report", description="This endpoint generates the daily report and sends it via email.", response_description="Daily email report sent successfully")
def generate_daily_email_report(db: Session = Depends(get_db)):
    send_daily_report(db)
    return {"message": "Daily email report sent successfully"}
