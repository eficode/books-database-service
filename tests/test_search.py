from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Search for a book - unsuccessful scenario
def test_search_book_no_results(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/search/?title=NonExistentBook")
    assert response.status_code == 404
    assert response.json().get("detail") == "No results found"
