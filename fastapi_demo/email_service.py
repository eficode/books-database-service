from email.mime.text import MIMEText
from smtplib import SMTP
from jinja2 import Template

SMTP_SERVER = "smtp.example.com"
SMTP_PORT = 587
SMTP_USERNAME = "your_username"
SMTP_PASSWORD = "your_password"


def send_email(to_address, subject, content):
    msg = MIMEText(content, "html")
    msg["Subject"] = subject
    msg["From"] = SMTP_USERNAME
    msg["To"] = to_address

    with SMTP(SMTP_SERVER, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        server.sendmail(SMTP_USERNAME, to_address, msg.as_string())


def generate_email_content(books):
    template = Template("""
    <h1>Most Sold Books</h1>
    <ul>
    {% for book in books %}
        <li>{{ book.title }} by {{ book.author }} - {{ book.sales }} copies sold</li>
    {% endfor %}
    </ul>
    """)
    return template.render(books=books)
