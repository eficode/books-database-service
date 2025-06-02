from pydantic import BaseModel

class SubscriptionOptIn(BaseModel):
    user_id: int

class DeliverySchedule(BaseModel):
    user_id: int

class ManageSubscription(BaseModel):
    user_id: int
    action: str
