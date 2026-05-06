import requests

AMAZON_API_URL = "https://api.amazon.com/product"
AMAZON_API_KEY = "your_amazon_api_key"


def fetch_amazon_price(isbn):
    response = requests.get(f"{AMAZON_API_URL}?isbn={isbn}&api_key={AMAZON_API_KEY}")
    if response.status_code == 200:
        data = response.json()
        return data['price']
    else:
        return None
