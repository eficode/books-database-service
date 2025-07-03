from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import UserBonus

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/{user_id}/bonus_points")
def get_bonus_points(user_id: int = Path(...), db: Session = Depends(get_db)):
    user_bonus = db.query(UserBonus).filter(UserBonus.user_id == user_id).first()
    if user_bonus is None:
        raise HTTPException(status_code=404, detail="User has not viewed their profile")
    return {"user_id": user_id, "total_bonus_points": user_bonus.bonus_points}
