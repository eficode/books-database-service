import requests
from fastapi import HTTPException

AMAZON_API_URL = "https://api.amazon.com/product"
AMAZON_API_KEY = "your_amazon_api_key"

class AmazonAPIError(Exception):
    pass

def fetch_book_price(isbn: str) -> float:
    try:
        response = requests.get(f"{AMAZON_API_URL}?isbn={isbn}&api_key={AMAZON_API_KEY}")
        response.raise_for_status()
        response_data = response.json()
        return response_data['price']
    except requests.RequestException:
        raise AmazonAPIError("Failed to fetch book price from Amazon API")
