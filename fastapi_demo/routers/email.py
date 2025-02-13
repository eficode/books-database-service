from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel
from ..utils import send_email

router = APIRouter()

class EmailRequest(BaseModel):
    to: str
    subject: str
    body: str

@router.post('/email/send', summary='Send Email', description='This endpoint sends an email with the provided details', response_description='Email sent successfully')
def send_email_endpoint(email_request: EmailRequest):
    response = send_email(email_request.to, email_request.subject, email_request.body)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail='Failed to send email')
    return {'message': 'Email sent successfully'}
