import requests

AMAZON_API_URL = "https://api.amazon.com/product"
AMAZON_API_KEY = "your_api_key"

class AmazonAPIError(Exception):
    pass

class AmazonService:
    @staticmethod
    def get_book_price(isbn):
        response = requests.get(f"{AMAZON_API_URL}/{isbn}", headers={"Authorization": f"Bearer {AMAZON_API_KEY}"})
        if response.status_code == 200:
            return response.json().get('price')
        raise AmazonAPIError("Prices are unavailable")
