from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favourite

client = TestClient(app)

# Add a book to favourites - unsuccessful scenario
def test_add_to_favourites_unsuccessful(mock_db_session):
    mock_db_session.add.side_effect = Exception("Database error")
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while adding the book to favourites"

# View favourites page - unsuccessful scenario
def test_view_favourites_unsuccessful(mock_db_session):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.get("/favourites/")
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while retrieving the favourites"

# Remove a book from favourites - unsuccessful scenario
def test_remove_from_favourites_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.side_effect = Exception("Database error")
    response = client.delete("/favourites/1")
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while removing the book from favourites"