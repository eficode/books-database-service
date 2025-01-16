def get_current_time():
    # This is a mock implementation of getting the current time
    from datetime import datetime
    return datetime.now().strftime('%I:%M %p')