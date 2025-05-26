import requests

class PaymentResponse:
    def __init__(self, status: str):
        self.status = status

class BookResponse:
    def __init__(self, book_id: int, title: str, author: str):
        self.book_id = book_id
        self.title = title
        self.author = author


def process_payment(payment_info: dict) -> PaymentResponse:
    response = requests.post("/payments/process", json=payment_info)
    if response.status_code == 200:
        return PaymentResponse(status=response.json().get("status"))
    return PaymentResponse(status="failed")


def fetch_top_selling_sci_fi_book() -> BookResponse:
    response = requests.get("/books/top-selling-sci-fi")
    if response.status_code == 200:
        data = response.json()
        return BookResponse(book_id=data.get("book_id"), title=data.get("title"), author=data.get("author"))
    return None
