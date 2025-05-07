from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Mock user authentication
def mock_get_current_user():
    return 1

app.dependency_overrides[get_current_user] = mock_get_current_user


def test_add_to_favourites_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, category="red")
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 201
    assert response.json().get("book_id") == 1


def test_add_to_favourites_not_red(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, category="blue")
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "Only red books can be added to favourites."


def test_add_to_favourites_error(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, category="red")
    mock_db_session.add.side_effect = Exception("DB Error")
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while adding the book to favourites."


def test_get_favourites_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [Favourite(id=1, user_id=1, book_id=1)]
    response = client.get("/favourites/")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("book_id") == 1


def test_get_favourites_error(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.side_effect = Exception("DB Error")
    response = client.get("/favourites/")
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while retrieving the favourites list."
