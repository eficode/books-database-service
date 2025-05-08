from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import MothersDayPresent
from fastapi_demo.dtos import MothersDayPresentCreate, MothersDayPresentInfo
from fastapi_demo.shipping_service import send_present

router = APIRouter()

@router.post('/mothers-day/presents/', response_model=MothersDayPresentInfo)
def create_mothers_day_present(present: MothersDayPresentCreate, db: Session = Depends(get_db)):
    if not present.recipient_address:
        raise HTTPException(status_code=400, detail='Shipping address is required')
    db_present = MothersDayPresent(**present.dict())
    db.add(db_present)
    db.commit()
    db.refresh(db_present)
    # Integrate with shipping service
    shipping_response = send_present(db_present)
    if not shipping_response['success']:
        if shipping_response['error'] == 'invalid_address':
            raise HTTPException(status_code=400, detail='Invalid shipping address')
        elif shipping_response['error'] == 'service_unavailable':
            raise HTTPException(status_code=503, detail='Shipping service is unavailable')
        elif shipping_response['error'] == 'out_of_stock':
            raise HTTPException(status_code=400, detail='Item is out of stock')
        else:
            raise HTTPException(status_code=400, detail='Shipping failed')
    db_present.status = 'shipped'
    db.commit()
    db.refresh(db_present)
    return MothersDayPresentInfo(id=db_present.id, status=db_present.status, message='Present shipped successfully')
