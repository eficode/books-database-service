def process_payment(payment_info):
    # Mock implementation for payment processing
    if payment_info['card_number'] == 'invalid':
        return {'success': False}
    return {'success': True}