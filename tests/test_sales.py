from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_get_ytd_sales():
    response = client.get("/sales/ytd")
    assert response.status_code == 200
    assert "current_year" in response.json()
    assert "previous_year" in response.json()
    assert "total_sales" in response.json()["current_year"]
    assert "sales_by_month" in response.json()["current_year"]
    assert "total_sales" in response.json()["previous_year"]
    assert "sales_by_month" in response.json()["previous_year"]


def test_filter_sales():
    response = client.get("/sales/filter", params={
        "date_range": "2023-01-01 to 2023-12-31",
        "product_category": "Electronics",
        "region": "North"
    })
    assert response.status_code == 200
    assert "filtered_sales" in response.json()
    assert all("date" in sale for sale in response.json()["filtered_sales"])
    assert all("category" in sale for sale in response.json()["filtered_sales"])
    assert all("region" in sale for sale in response.json()["filtered_sales"])
    assert all("sales" in sale for sale in response.json()["filtered_sales"])


def test_generate_sales_report():
    response = client.post("/sales/report")
    assert response.status_code == 201
    assert "report_id" in response.json()
    assert "report_url" in response.json()
