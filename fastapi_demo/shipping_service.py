import requests

def send_present(present):
    shipping_data = {
        'recipient_name': present.recipient_name,
        'recipient_address': present.recipient_address,
        'item_id': present.present_id
    }
    try:
        response = requests.post('https://shipping-service.example.com/api/ship', json=shipping_data)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as err:
        if response.status_code == 400:
            return {'success': False, 'error': 'invalid_address'}
        elif response.status_code == 503:
            return {'success': False, 'error': 'service_unavailable'}
        elif response.status_code == 404:
            return {'success': False, 'error': 'out_of_stock'}
        else:
            return {'success': False, 'error': 'unknown_error'}
    except requests.exceptions.RequestException as err:
        return {'success': False, 'error': 'service_unavailable'}
