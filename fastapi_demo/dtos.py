from pydantic import BaseModel, Field, validator
from typing import Optional, Dict

class Address(BaseModel):
    street: str
    city: str
    state: str
    zip_code: str
    country: str

class GiftCreate(BaseModel):
    book_id: int
    mother_address: Optional[Address] = None
    personal_message: Optional[str] = None

    @validator('mother_address')
    def check_mother_address(cls, v):
        if v is None:
            raise ValueError('Mother\'s shipping address is required')
        return v

class GiftInfo(BaseModel):
    id: int
    book_id: int
    mother_address: Dict[str, str]
    personal_message: Optional[str]
    status: str
    created_at: str
    updated_at: str
