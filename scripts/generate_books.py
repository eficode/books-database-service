"""
Script to generate 100 sample books with various categories
"""
import sys
import os
import random
from sqlalchemy.orm import Session

# Add parent directory to path so we can import from fastapi_demo
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import get_db, engine, Base
from fastapi_demo.models import Book  # Import early to avoid circular imports

# Sample data
authors = [
    "J.K. Rowling", "George R.R. Martin", "Stephen King", "Neil Gaiman",
    "Brandon Sanderson", "Agatha Christie", "Jane Austen", "Ernest Hemingway",
    "Mark Twain", "Leo Tolstoy", "F. Scott Fitzgerald", "Virginia Woolf",
    "Gabriel García Márquez", "Haruki Murakami", "Margaret Atwood", "Toni Morrison",
    "Charles Dickens", "Homer", "Dante Alighieri", "J.R.R. Tolkien"
]

categories = [
    "Fiction", "Non-Fiction", "Fantasy", "Science Fiction", "Mystery", 
    "Thriller", "Horror", "Romance", "Historical Fiction", "Biography",
    "Self-Help", "Business", "Science", "History", "Poetry",
    "Children's Books", "Young Adult", "Travel", "Cookbooks", "Philosophy"
]

title_prefixes = [
    "The", "A", "Chronicles of", "Tales of", "Guide to", "Journey to", 
    "Adventures in", "Secrets of", "History of", "Life of",
    "Art of", "Science of", "World of", "Masters of", "Legend of",
    "Mystery of", "Rise of", "Fall of", "Path to", "Return to"
]

title_subjects = [
    "Dragon", "Mountain", "Ocean", "Forest", "Castle", 
    "Kingdom", "Empire", "War", "Peace", "Love", 
    "Death", "Life", "Future", "Past", "Mind",
    "Heart", "Star", "Planet", "Universe", "Society",
    "Family", "Friend", "Enemy", "Hero", "Villain"
]

title_suffixes = [
    "Awakening", "Redemption", "Chronicles", "Tales", "Stories",
    "Adventure", "Journey", "Quest", "Saga", "Mystery",
    "Conspiracy", "Legacy", "Prophecy", "Destiny", "Revelation",
    "Twilight", "Dawn", "Dusk", "Night", "Day"
]

def generate_title():
    """Generate a random book title"""
    if random.random() < 0.7:
        prefix = random.choice(title_prefixes)
        subject = random.choice(title_subjects)
        if random.random() < 0.5:
            suffix = random.choice(title_suffixes)
            return f"{prefix} {subject} {suffix}"
        return f"{prefix} {subject}"
    else:
        subject = random.choice(title_subjects)
        suffix = random.choice(title_suffixes)
        return f"{subject} {suffix}"

def generate_books(db: Session, count: int = 100):
    """Generate a specified number of random books"""
    books = []
    
    for _ in range(count):
        title = generate_title()
        author = random.choice(authors)
        pages = random.randint(100, 1000)
        category = random.choice(categories)
        
        book = Book(
            title=title,
            author=author,
            pages=pages,
            category=category,
            favorite=random.random() < 0.2  # About 20% of books set as favorites
        )
        db.add(book)
    
    db.commit()
    print(f"Generated {count} random books")

def main():
    # Create all tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    # Get database session
    db = next(get_db())
    
    # Generate books
    generate_books(db)

if __name__ == "__main__":
    main()