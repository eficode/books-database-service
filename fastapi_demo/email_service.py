import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from cryptography.fernet import Fernet
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

# Function to send email
def send_email(to, subject, body):
    # Encrypt the email content
    key = b'your-encryption-key-here'  # Use a secure method to store and retrieve the key
    cipher_suite = Fernet(key)
    encrypted_body = cipher_suite.encrypt(body.encode())

    msg = MIMEMultipart()
    msg['From'] = 'no-reply@example.com'
    msg['To'] = to
    msg['Subject'] = subject
    msg.attach(MIMEText(encrypted_body.decode(), 'plain'))

    server = smtplib.SMTP('smtp.example.com', 587)
    server.starttls()
    server.login('username', 'password')
    text = msg.as_string()
    server.sendmail('no-reply@example.com', to, text)
    server.quit()

    # Log the email sending event
    logging.info(f"Email sent to {to} with subject '{subject}'")