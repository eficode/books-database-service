from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from .models import Gift

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
