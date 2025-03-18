from datetime import date
from fastapi_demo.dtos import BookCreate, BookInfo

def test_book_create_schema():
    book_data = {
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "category": "Fiction",
        "favorite": False,
        "published_date": date(2024, 3, 18)
    }
    book = BookCreate(**book_data)
    assert book.title == "Test Book"
    assert book.author == "Test Author"
    assert book.pages == 100
    assert book.category == "Fiction"
    assert book.favorite is False
    assert book.published_date == date(2024, 3, 18)

def test_book_info_schema():
    book_data = {
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "category": "Fiction",
        "favorite": False,
        "published_date": date(2024, 3, 18),
        "id": 1
    }
    book = BookInfo(**book_data)
    assert book.id == 1
    assert book.title == "Test Book"
    assert book.author == "Test Author"
    assert book.pages == 100
    assert book.category == "Fiction"
    assert book.favorite is False
    assert book.published_date == date(2024, 3, 18)
