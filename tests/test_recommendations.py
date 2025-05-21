from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_get_recommendations_valentines_day_no_recommendations():
    response = client.post("/recommendations/occasion", json={"occasion": "Valentine's Day"})
    assert response.status_code == 404
    assert response.json()["detail"] == "No recommendations available for Valentine's Day"


def test_get_recommendations_mothers_day_no_recommendations():
    response = client.post("/recommendations/occasion", json={"occasion": "Mother's Day"})
    assert response.status_code == 404
    assert response.json()["detail"] == "No recommendations available for Mother's Day"


def test_get_recommendations_best_colleague_day_no_recommendations():
    response = client.post("/recommendations/occasion", json={"occasion": "Best Colleague Day"})
    assert response.status_code == 404
    assert response.json()["detail"] == "No recommendations available for Best Colleague Day"
