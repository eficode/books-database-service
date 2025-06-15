import pytest
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.database import Base, engine, get_db
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Use in-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_gifts.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create test database
Base.metadata.create_all(bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

def test_create_gift():
    # First create a book
    book_data = {
        "title": "Test Book for Gift",
        "author": "Test Author",
        "pages": 200,
        "category": "Fiction",
        "price": 15.99
    }
    book_response = client.post("/books/", json=book_data)
    assert book_response.status_code == 200
    book = book_response.json()
    
    # Now create a gift order with GDPR consent
    gift_data = {
        "book_id": book["id"],
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St, New York, NY 10001",
        "recipient_country": "USA",
        "consent_given": True
    }
    response = client.post("/gifts/", json=gift_data)
    assert response.status_code == 200
    
    gift = response.json()
    assert gift["book_id"] == book["id"]
    assert gift["status"] == "pending"
    assert gift["consent_given"] == True
    assert gift["purpose"] == "gift_delivery"
    assert "id" in gift
    assert "created_at" in gift
    assert "data_retention_until" in gift

def test_create_gift_without_consent():
    # First create a book
    book_data = {
        "title": "Test Book for Gift",
        "author": "Test Author", 
        "pages": 200,
        "category": "Fiction",
        "price": 15.99
    }
    book_response = client.post("/books/", json=book_data)
    assert book_response.status_code == 200
    book = book_response.json()
    
    # Try to create gift without consent
    gift_data = {
        "book_id": book["id"],
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St, New York, NY 10001",
        "recipient_country": "USA",
        "consent_given": False
    }
    response = client.post("/gifts/", json=gift_data)
    assert response.status_code == 400
    assert "consent" in response.json()["detail"].lower()

def test_create_gift_book_not_found():
    gift_data = {
        "book_id": 99999,  # Non-existent book ID
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St, New York, NY 10001",
        "recipient_country": "USA",
        "consent_given": True
    }
    response = client.post("/gifts/", json=gift_data)
    assert response.status_code == 404
    assert response.json()["detail"] == "Book not found"

def test_get_gifts():
    response = client.get("/gifts/")
    assert response.status_code == 200
    gifts = response.json()
    assert isinstance(gifts, list)

def test_gdpr_access_request():
    # Create a test gift first
    book_data = {
        "title": "GDPR Test Book",
        "author": "Privacy Author",
        "pages": 300,
        "category": "Legal",
        "price": 25.99
    }
    book_response = client.post("/books/", json=book_data)
    book = book_response.json()
    
    gift_data = {
        "book_id": book["id"],
        "recipient_name": "Jane Privacy",
        "recipient_address": "456 GDPR Street, Privacy City",
        "recipient_country": "EU",
        "consent_given": True
    }
    gift_response = client.post("/gifts/", json=gift_data)
    assert gift_response.status_code == 200
    
    # Test GDPR access request
    access_request = {
        "request_type": "access",
        "subject_identifier": "Jane Privacy"
    }
    response = client.post("/gifts/gdpr/access", json=access_request)
    assert response.status_code == 200
    
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert data[0]["consent_given"] == True

def test_gdpr_erasure_request():
    # Create a test gift first
    book_data = {
        "title": "Erasure Test Book",
        "author": "Delete Author",
        "pages": 100,
        "category": "Test",
        "price": 10.00
    }
    book_response = client.post("/books/", json=book_data)
    book = book_response.json()
    
    gift_data = {
        "book_id": book["id"],
        "recipient_name": "Delete Me",
        "recipient_address": "123 Forget Lane",
        "recipient_country": "Nowhere",
        "consent_given": True
    }
    gift_response = client.post("/gifts/", json=gift_data)
    gift = gift_response.json()
    
    # Test GDPR erasure request
    response = client.delete(f"/gifts/gdpr/erase/{gift['id']}")
    assert response.status_code == 200
    assert "deleted" in response.json()["message"].lower()
    
    # Verify the gift is actually deleted
    get_response = client.get(f"/gifts/{gift['id']}")
    assert get_response.status_code == 404

def test_data_retention_info():
    response = client.get("/gifts/gdpr/retention-info")
    assert response.status_code == 200
    retention_info = response.json()
    assert isinstance(retention_info, list)
