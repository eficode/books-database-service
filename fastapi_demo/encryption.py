"""
Encryption utilities for GDPR compliance
"""
import os
from cryptography.fernet import Fernet
from typing import Optional

# In production, this should be loaded from environment variables or secure key management
# For development, use a fixed key (DO NOT use in production)
DEFAULT_KEY = b'ZmDfcTF7_60GrrY167zsiPd67pEvs0aGOv2oasOM1Pg='  # Fixed key for development
ENCRYPTION_KEY = os.getenv('ENCRYPTION_KEY', DEFAULT_KEY.decode() if isinstance(DEFAULT_KEY, bytes) else DEFAULT_KEY)
cipher_suite = Fernet(ENCRYPTION_KEY.encode() if isinstance(ENCRYPTION_KEY, str) else ENCRYPTION_KEY)

def encrypt_data(plaintext: str) -> str:
    """Encrypt plaintext data for storage"""
    if not plaintext:
        return ""
    return cipher_suite.encrypt(plaintext.encode()).decode()

def decrypt_data(ciphertext: str) -> str:
    """Decrypt data for use"""
    if not ciphertext:
        return ""
    return cipher_suite.decrypt(ciphertext.encode()).decode()

def is_encrypted(data: str) -> bool:
    """Check if data appears to be encrypted (basic heuristic)"""
    if not data:
        return False
    try:
        # Fernet tokens are base64 encoded and start with 'gAAAAA'
        return data.startswith('gAAAAA') and len(data) > 60
    except:
        return False
