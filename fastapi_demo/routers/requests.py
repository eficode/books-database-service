from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Request, User
from fastapi_demo.dependencies import get_current_user

router = APIRouter()

@router.post("/requests/{request_id}/approve")
def approve_request(request_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Check if the user is a middle manager
    if current_user.role != 'middle_manager':
        raise HTTPException(status_code=403, detail="Permission denied")

    # Fetch the request from the database
    request = db.query(Request).filter(Request.id == request_id).first()
    if request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    try:
        # Update the request status to 'Approved'
        request.status = 'Approved'
        db.commit()
        db.refresh(request)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail="Failed to process approval")

    return {"id": request.id, "status": request.status, "message": "Request approved successfully"}
