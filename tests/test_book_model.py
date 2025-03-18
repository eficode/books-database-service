from datetime import date
from fastapi_demo.models import Book

def test_book_model():
    # Create a book instance with a published_date
    book = Book(
        title="Test Book",
        author="Test Author",
        pages=100,
        category="Fiction",
        favorite=False,
        published_date=date(2024, 3, 18)
    )
    
    # Assert that the published_date is set correctly
    assert book.published_date == date(2024, 3, 18)
    assert book.category == "Fiction"
    assert book.favorite is False
