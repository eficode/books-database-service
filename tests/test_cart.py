from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Mock user authentication
def mock_get_current_user():
    return 1

app.dependency_overrides[get_current_user] = mock_get_current_user


def test_add_to_cart_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favourite(id=1, user_id=1, book_id=1)
    response = client.post("/cart/", json={"book_id": 1})
    assert response.status_code == 201
    assert response.json().get("book_id") == 1


def test_add_to_cart_not_in_favourites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/cart/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is not in your favourites list."


def test_add_to_cart_error(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favourite(id=1, user_id=1, book_id=1)
    mock_db_session.add.side_effect = Exception("DB Error")
    response = client.post("/cart/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while adding the book to the cart."
