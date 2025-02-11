import schedule
import time
from .email_service import send_email_report

# Schedule the task
schedule.every().day.at("08:00").do(send_email_report)

while True:
    schedule.run_pending()
    time.sleep(1)
