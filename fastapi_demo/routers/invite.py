from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr, ValidationError
from typing import List
from sqlalchemy.orm import Session
from ..database import get_db

router = APIRouter()

class EmailInviteRequest(BaseModel):
    emails: List[EmailStr]

class SocialInviteRequest(BaseModel):
    platform: str
    link: str

@router.post('/invite/email')
def invite_friends_via_email(request: EmailInviteRequest, db: Session = Depends(get_db)):
    try:
        for email in request.emails:
            # Logic to send email
            send_email_invitation(email)
        return {"message": "Invitations sent successfully"}
    except ValidationError as e:
        raise HTTPException(status_code=400, detail="Invalid email address")

@router.post('/invite/social')
def invite_friends_via_social(request: SocialInviteRequest, db: Session = Depends(get_db)):
    try:
        # Logic to share on social media
        share_on_social_media(request.platform, request.link)
        return {"message": "Invitation shared successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail="Failed to share on social media")

# Placeholder functions for sending email and sharing on social media
def send_email_invitation(email: str):
    pass

def share_on_social_media(platform: str, link: str):
    pass
