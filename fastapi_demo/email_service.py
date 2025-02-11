from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from .config import settings
from .database import SessionLocal
from .routers.sales import get_daily_report

conf = ConnectionConfig(
    MAIL_USERNAME=settings.MAIL_USERNAME,
    MAIL_PASSWORD=settings.MAIL_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.MAIL_PORT,
    MAIL_SERVER=settings.MAIL_SERVER,
    MAIL_TLS=True,
    MAIL_SSL=False
)

async def send_email_report():
    db = SessionLocal()
    try:
        report = get_daily_report(db)
        if not report["report"]:
            return
        message = MessageSchema(
            subject="Daily Sales Report",
            recipients=["sales_manager@bookbridge.com"],
            body=str(report),
            subtype="html"
        )
        fm = FastMail(conf)
        await fm.send_message(message)
    finally:
        db.close()
