from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone


class Book(Base):
    __tablename__ = "books"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)
    price = Column(Float, default=9.99)
    stock = Column(Integer, default=10)
    
    basket_items = relationship("BasketItem", back_populates="book")


class Basket(Base):
    __tablename__ = "baskets"
    
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed = Column(Boolean, default=False)
    
    items = relationship("BasketItem", back_populates="basket", cascade="all, delete-orphan")


class BasketItem(Base):
    __tablename__ = "basket_items"
    
    id = Column(Integer, primary_key=True, index=True)
    basket_id = Column(Integer, ForeignKey("baskets.id"))
    book_id = Column(Integer, ForeignKey("books.id"))
    quantity = Column(Integer, default=1)
    
    basket = relationship("Basket", back_populates="items")
    book = relationship("Book", back_populates="basket_items")


class Gift(Base):
    __tablename__ = "gifts"
    
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey('books.id'))
    
    # Encrypted personal data
    recipient_name_encrypted = Column(String)
    recipient_address_encrypted = Column(String)
    recipient_country_encrypted = Column(String)
    
    # GDPR compliance fields
    consent_given = Column(Boolean, default=False)
    consent_timestamp = Column(DateTime)
    purpose = Column(String, default='gift_delivery')
    data_retention_until = Column(DateTime)  # Auto-delete date
    
    # System fields
    status = Column(String, default='pending')
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    last_accessed = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    
    book = relationship("Book")
    
    # Legacy fields for backward compatibility (will be migrated)
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    recipient_country = Column(String)
    
    def set_recipient_data(self, name: str, address: str, country: str):
        """Set recipient data with encryption"""
        from .encryption import encrypt_data
        self.recipient_name_encrypted = encrypt_data(name)
        self.recipient_address_encrypted = encrypt_data(address)
        self.recipient_country_encrypted = encrypt_data(country)
        self.last_accessed = datetime.now(timezone.utc)
    
    def get_recipient_data(self) -> dict:
        """Get decrypted recipient data"""
        from .encryption import decrypt_data, is_encrypted
        
        # Use encrypted data if available, fall back to legacy fields
        name = self.recipient_name_encrypted or self.recipient_name
        address = self.recipient_address_encrypted or self.recipient_address
        country = self.recipient_country_encrypted or self.recipient_country
        
        # Decrypt if encrypted
        if is_encrypted(name):
            name = decrypt_data(name)
        if is_encrypted(address):
            address = decrypt_data(address)
        if is_encrypted(country):
            country = decrypt_data(country)
            
        self.last_accessed = datetime.now(timezone.utc)
        return {
            "name": name,
            "address": address,
            "country": country
        }


class GiftDataAccess(Base):
    """Audit log for GDPR compliance - tracks all access to gift data"""
    __tablename__ = "gift_data_access"
    
    id = Column(Integer, primary_key=True, index=True)
    gift_id = Column(Integer, ForeignKey('gifts.id'))
    access_type = Column(String)  # CREATE, READ, UPDATE, DELETE
    accessed_by = Column(String)  # User/system identifier
    access_purpose = Column(String)  # Why data was accessed
    ip_address = Column(String)
    user_agent = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    gift = relationship("Gift")
