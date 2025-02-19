from pydantic import BaseModel

class User(BaseModel):
    id: int
    is_test_manager: bool
