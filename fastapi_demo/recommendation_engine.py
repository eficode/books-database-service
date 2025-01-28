from typing import List
from .models import Book

# Mock function to simulate recommendation engine
# In a real-world scenario, this would involve complex logic or a third-party service

def get_similar_books(book_id: int) -> List[Book]:
    # Mock data for similar books
    similar_books = [
        Book(id=2, title="Similar Book 1", author="Author 1", pages=300),
        Book(id=3, title="Similar Book 2", author="Author 2", pages=250)
    ]
    return similar_books
