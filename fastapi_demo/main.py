from fastapi import FastAPI
from .database import Base, engine
from .routers.books import router as books
from .routers.reports import router as reports
from .services.report_service import send_daily_report
from apscheduler.schedulers.background import BackgroundScheduler

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books)
app.include_router(reports)


def schedule_daily_report():
    scheduler = BackgroundScheduler()
    scheduler.add_job(send_daily_report, 'cron', hour=8, args=[next(get_db())])
    scheduler.start()


@app.on_event('startup')
def startup_event():
    schedule_daily_report()
