from fastapi import FastAPI
from .database import Base, engine
from .routers.books import router as books_router
from .routers.reports import router as reports_router
from .routers.email import router as email_router
from apscheduler.schedulers.background import BackgroundScheduler
from .utils import get_least_sold_books, generate_report, send_email
from .database import get_db

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books_router)
app.include_router(reports_router)
app.include_router(email_router)

# Scheduled Task
def scheduled_task():
    db = next(get_db())
    books = get_least_sold_books(db)
    report = generate_report(books)
    send_email('sales_manager@bookbridge.com', 'Top 10 Least Sold Books', report)

scheduler = BackgroundScheduler()
scheduler.add_job(scheduled_task, 'cron', hour=8)
scheduler.start()
