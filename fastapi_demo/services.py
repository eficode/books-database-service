class ShippingService:
    def ship_book(self, recipient_name: str, recipient_address: str, book_id: int) -> str:
        # Logic to integrate with shipping provider
        if not recipient_address or len(recipient_address) < 10:
            raise ValueError("Invalid shipping details")
        return "tracking_number"

class EmailService:
    def send_confirmation(self, recipient_email: str, purchase_details: dict):
        # Logic to send email
        pass
