Purpose

Allow BookBridge customers to send a book as a gift to their friends in another country without needing to buy it first and send it separately.

Feature: Send Book as Gift

Aptance Criteria Scenarios

Scenario 1: Select book to send as gift - successful scenario
Given I am a logged-in BookBridge customer
When I browse the book catalog
And I select a book
And I choose the option to send it as a gift
Then I should be prompted to enter the recipient's details

Scenario 2: Enter recipient details - successful scenario
Given I have selected a book to send as a gift
When I enter the recipient's name, address, and country
And I confirm the details
Then I should see a confirmation message that the book will be sent as a gift

Scenario 3: Enter recipient details - unsuccessful scenario
Given I have selected a book to send as a gift
When I enter the recipient's name, address, and country
And I do not confirm the details
Then I should see an error message indicating that the details are incomplete

Scenario 4: Confirm gift order - successful scenario
Given I have entered the recipient's details
When I confirm the gift order
Then the book should be added to the gift orders queue
And I should receive an email confirmation of the gift order

Scenario 5 :Confirm gift order - unsuccessful scenario
Given I have entered the recipient's details
When I confirm the gift order
And the book is not in stock anymore
Then I should see an error message indicating that the order could not be processed because book is out of stock

Dependencies

Integration with the book catalog system

Integration with the order processing system

Email service for sending confirmation emails

Design Mockups

Design mockups can be found in the shared design folder under 'Gift Feature Mockups'.

Technical Feasibility

The technical approach involves creating new endpoints in the FastAPI backend to handle gift orders and integrating with the existing order processing system.

Performance Criteria

The system should handle up to 1000 gift orders per minute without degradation in performance.

Security Considerations

Ensure that the collection of recipient details (name, address, and country) is done securely and that data is encrypted both in transit and at rest.

Implement data minimization by only collecting the necessary information required to send the gift (e.g., avoid collecting unnecessary personal data).

Ensure that the purpose limitation principle is adhered to by using the recipient's data solely for the purpose of sending the gift and not for any other purposes.

Provide clear information to the customer about how the recipient's data will be used and obtain explicit consent before processing the data.

Implement access controls to ensure that only authorized personnel can access the recipient's data.

Ensure that the data retention policy is in place to delete the recipient's data after the gift has been sent and any necessary retention period has expired.

Conduct regular security audits and vulnerability assessments to identify and mitigate potential risks.

Ensure compliance with GDPR by providing mechanisms for data subjects to exercise their rights, such as the right to access, rectify, and erase their data.

Testability

Test cases should include scenarios for selecting a book, entering recipient details, confirming the gift order, and receiving email confirmation.

User Story key: https://eficode-ai.atlassian.net/browse/GENAI-349#icft=GENAI-349

Technological Design: 

API Endpoints

POST /gifts/

Request Body:
  

{
    "book_id": "integer",
    "recipient_name": "string",
    "recipient_address": "string",
    "recipient_country": "string"
  }

Response:
  

HTTP/1.1 201 Created
  Content-Type: application/json
  {
    "gift_id": "integer",
    "book_id": "integer",
    "recipient_name": "string",
    "recipient_address": "string",
    "recipient_country": "string",
    "status": "string"
  }

Implementation Details

1. Database Schema Changes

Add a new table `gifts` to store gift orders.
   

from sqlalchemy import Column, Integer, String, ForeignKey
   from .database import Base

   class Gift(Base):
       __tablename__ = "gifts"
       id = Column(Integer, primary_key=True, index=True)
       book_id = Column(Integer, ForeignKey('books.id'))
       recipient_name = Column(String, index=True)
       recipient_address = Column(String)
       recipient_country = Column(String)
       status = Column(String, default='pending')

2. Models

Create Pydantic models for gift creation and response.
   

from pydantic import BaseModel
   from typing import Optional

   class GiftCreate(BaseModel):
       book_id: int
       recipient_name: str
       recipient_address: str
       recipient_country: str

   class GiftInfo(GiftCreate):
       id: Optional[int] = None
       status: Optional[str] = None

3. API Endpoint Implementation

Implement the endpoint to handle gift creation.
   

from fastapi import FastAPI, Depends, HTTPException
   from .database import get_db, engine, Base
   from .models import Gift, GiftCreate, GiftInfo
   from sqlalchemy.orm import Session

   app = FastAPI()
   Base.metadata.create_all(bind=engine)

   @app.post("/gifts/", response_model=GiftInfo)
   def create_gift(gift: GiftCreate, db: Session = Depends(get_db)):
       db_gift = Gift(**gift.dict())
       db.add(db_gift)
       db.commit()
       db.refresh(db_gift)
       return GiftInfo(**db_gift.__dict__)

4. Email Service Integration

Integrate with the email service to send confirmation emails.
   

from fastapi import BackgroundTasks
   from .email_service import send_email

   @app.post("/gifts/", response_model=GiftInfo)
   def create_gift(gift: GiftCreate, db: Session = Depends(get_db), background_tasks: BackgroundTasks):
       db_gift = Gift(**gift.dict())
       db.add(db_gift)
       db.commit()
       db.refresh(db_gift)
       background_tasks.add_task(send_email, db_gift)
       return GiftInfo(**db_gift.__dict__)

5. Email Service Implementation

Implement the email service to send confirmation emails.
   

from fastapi_mail import FastMail, MessageSchema, ConnectionConfig

   conf = ConnectionConfig(
       MAIL_USERNAME = "your_username",
       MAIL_PASSWORD = "your_password",
       MAIL_FROM = "your_email",
       MAIL_PORT = 587,
       MAIL_SERVER = "your_mail_server",
       MAIL_TLS = True,
       MAIL_SSL = False
   )

   def send_email(gift: Gift):
       message = MessageSchema(
           subject="Your gift order confirmation",
           recipients=["recipient@example.com"],
           body=f"Your gift order for {gift.book_id} has been placed successfully.",
           subtype="html"
       )
       fm = FastMail(conf)
       fm.send_message(message)

Definition of Done Criteria

1. Code Written: The task has been fully coded and implements the solution as specified.
2. Code Reviewed: The code has undergone peer review and meets team coding standards.
3. Unit Tests Passed: All unit tests written for the task pass successfully.
4. Integration Testing: The code has been integrated and tested with the system to ensure it works as expected.
5. Documentation Updated: Relevant documentation (e.g., technical, user guides) has been updated to reflect changes.
6. Acceptance Criteria Met: The task meets all defined acceptance criteria from the specification.
7. No Known Bugs: There are no known defects or bugs in the implemented task.
8. Deployed to Staging: The code has been deployed to a staging environment for further testing.
9. Product Owner Approval: The implementation has been reviewed and approved by the Product Owner or relevant stakeholder.
