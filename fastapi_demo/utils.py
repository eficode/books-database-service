import os
from fastapi import UploadFile

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MB


def save_file_to_storage(file: UploadFile) -> str:
    # Dummy implementation for saving file to storage and returning the URL
    file_location = f"static/{file.filename}"
    with open(file_location, "wb") as f:
        f.write(file.file.read())
    return f"/static/{file.filename}"


def validate_file_format(filename: str) -> bool:
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def validate_file_size(file: UploadFile) -> bool:
    file.file.seek(0, os.SEEK_END)
    file_size = file.file.tell()
    file.file.seek(0, os.SEEK_SET)
    return file_size <= MAX_FILE_SIZE


def simulate_network_failure() -> bool:
    # Dummy implementation for simulating network failure
    return False


def simulate_server_error() -> bool:
    # Dummy implementation for simulating server error
    return False
