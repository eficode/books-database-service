from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

client = TestClient(app)

# Test for unsupported language
def test_search_best_selling_books_unsupported_language():
    response = client.get('/books/best-selling?language=jp')  # Assuming 'jp' is not in SUPPORTED_LANGUAGES
    assert response.status_code == 400
    assert response.json().get('detail') == 'Language not supported'

# Test for no best-selling books found
def test_search_best_selling_books_no_books_found():
    response = client.get('/books/best-selling?language=en')  # Assuming no books in 'en' language
    assert response.status_code == 404
    assert response.json().get('detail') == 'No best-selling books found for the specified language'

# Test for successful search
def test_search_best_selling_books_success(monkeypatch):
    class MockQuery:
        def filter(self, *args, **kwargs):
            return self
        def order_by(self, *args, **kwargs):
            return self
        def all(self):
            return [
                Book(id=1, title='Test Book', author='Test Author', pages=100, language='en', sales=1000)
            ]

    def mock_get_db():
        yield MockQuery()

    monkeypatch.setattr('fastapi_demo.routers.books.get_db', mock_get_db)
    response = client.get('/books/best-selling?language=en')
    assert response.status_code == 200
    books = response.json()
    assert len(books) == 1
    assert books[0]['title'] == 'Test Book'
    assert books[0]['author'] == 'Test Author'
    assert books[0]['pages'] == 100
    assert books[0]['language'] == 'en'
