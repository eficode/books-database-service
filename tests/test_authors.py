from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Author

client = TestClient(app)

# Test for unsuccessful scenario: View authors in non-alphabetical order
def test_list_authors_non_alphabetical(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Author(id=1, name='Zoe', stars=5),
        Author(id=2, name='Alice', stars=3)
    ]
    response = client.get('/authors/')
    assert response.status_code == 200
    authors = response.json()
    assert authors[0]['name'] == 'Zoe'
    assert authors[1]['name'] == 'Alice'

# Test for unsuccessful scenario: Fail to rank authors by stars
def test_rank_author_fail(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post('/authors/1/rank', json={'stars': 5})
    assert response.status_code == 404
    assert response.json()['detail'] == 'Author not found'
