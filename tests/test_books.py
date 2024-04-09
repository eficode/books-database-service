# FILEPATH: /Users/alexjantunen/dev/fast-api-demo/test_main.py
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app, get_db, Book
from fastapi import HTTPException

client = TestClient(app)

def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100
    })

    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
