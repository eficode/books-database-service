from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_start_demo_mode():
    response = client.post("/demo-mode/start")
    assert response.status_code == 200
    assert response.json().get("message") == "Demo mode started"
    assert "demoSessionId" in response.json()


def test_stop_demo_mode_success():
    start_response = client.post("/demo-mode/start")
    demo_session_id = start_response.json().get("demoSessionId")
    response = client.post("/demo-mode/stop", json={"demoSessionId": demo_session_id})
    assert response.status_code == 200
    assert response.json().get("message") == "Demo mode stopped"


def test_stop_demo_mode_not_found():
    response = client.post("/demo-mode/stop", json={"demoSessionId": "nonexistent_id"})
    assert response.status_code == 404
    assert response.json().get("detail") == "Demo session not found"
