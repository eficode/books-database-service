import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_SERVER = 'smtp.example.com'
SMTP_PORT = 587
SMTP_USERNAME = 'your_username'
SMTP_PASSWORD = 'your_password'

RECIPIENT_EMAIL = 'sales_manager@example.com'

def send_email(books):
    subject = "Daily Report: Most Sold Books"
    body = "<h1>Most Sold Books</h1><ul>"
    for book in books:
        body += f"<li>{book['title']} by {book['author']} - {book['sales']} sales</li>"
    body += "</ul>"

    msg = MIMEMultipart()
    msg['From'] = SMTP_USERNAME
    msg['To'] = RECIPIENT_EMAIL
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'html'))

    with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        server.sendmail(SMTP_USERNAME, RECIPIENT_EMAIL, msg.as_string())