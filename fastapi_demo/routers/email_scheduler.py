from fastapi import APIRouter, HTTPException
from ..email_service import send_weekly_email

router = APIRouter(
    prefix="/email_scheduler",
    tags=["email_scheduler"]
)

@router.post("/send_weekly_email", summary="Send Weekly Email", description="This endpoint sends the weekly highest-rated books email.", response_description="Confirmation message")
def send_weekly_email_endpoint():
    try:
        send_weekly_email()
    except Exception as e:
        raise HTTPException(status_code=500, detail="Weekly email not sent")
    return {"message": "Weekly email sent"}