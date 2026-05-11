import requests

AMAZON_API_URL = "https://api.amazon.com/product"
AMAZON_API_KEY = "your_amazon_api_key"

def fetch_book_price(isbn):
    response = requests.get(f"{AMAZON_API_URL}/{isbn}", headers={"Authorization": f"Bearer {AMAZON_API_KEY}"})
    if response.status_code == 200:
        return response.json().get('price')
    else:
        return None
