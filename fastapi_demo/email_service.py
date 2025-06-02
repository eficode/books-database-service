import smtplib
from email.mime.text import MIMEText

def send_email(to_address, subject, body):
    from_address = "no-reply@bookbridge.com"
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = from_address
    msg['To'] = to_address
    with smtplib.SMTP('smtp.bookbridge.com') as server:
        server.login("username", "password")
        server.sendmail(from_address, [to_address], msg.as_string())
