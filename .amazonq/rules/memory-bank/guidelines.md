# Books Database Service - Development Guidelines

## Code Quality Standards

### Python Code Formatting
- **Import Organization**: Standard library imports first, then third-party imports, then local imports with relative imports (`.` notation)
- **Line Length**: Keep lines reasonably short, break long function signatures across multiple lines
- **Docstrings**: Use triple-quoted strings for module-level documentation
- **Type Hints**: Use type hints for function parameters and return values (e.g., `List[BookInfo]`, `Session`, `int`)
- **Naming Conventions**: 
  - snake_case for functions, variables, and module names
  - PascalCase for class names
  - UPPER_CASE for constants

### JavaScript Code Formatting
- **Const/Let**: Use `const` for immutable references, avoid `var`
- **Arrow Functions**: Use arrow functions for callbacks and inline functions
- **Template Literals**: Use backticks for string interpolation
- **Async/Await**: Prefer async/await over promise chains for asynchronous operations
- **Comments**: Use `//` for single-line comments describing sections

### Structural Conventions
- **Single Responsibility**: Each file has a clear, focused purpose (e.g., `books.py` only handles book routes)
- **Separation of Concerns**: DTOs, models, database, and routes are in separate files
- **Flat Structure**: Keep directory nesting minimal (max 2-3 levels)
- **Resource-Based Organization**: Group related functionality by resource (e.g., `routers/books.py`)

## FastAPI Patterns

### Router Configuration
```python
router = APIRouter(
    prefix="/books",
    tags=["books"]
)
```
- Always use `APIRouter` for organizing endpoints
- Set meaningful prefix and tags for API documentation
- Keep routers focused on a single resource

### Endpoint Definitions
```python
@router.get("/", response_model=List[BookInfo],
         summary="Get all books",
         description="This endpoint retrieves all books from the database",
         response_description="A list of all books")
def read_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return [BookInfo(**book.__dict__) for book in books]
```
- **Always specify `response_model`** for type safety and automatic documentation
- **Include `summary` and `description`** for clear API documentation
- **Use dependency injection** with `Depends(get_db)` for database sessions
- **HTTP method semantics**: GET (read), POST (create), PUT (update), DELETE (delete), PATCH (partial update)

### Path Parameters
```python
@router.get("/{book_id}", response_model=BookInfo)
def read_book(
    book_id: int = Path(..., description="The ID of the book to be retrieved", examples=1),
    db: Session = Depends(get_db)):
```
- Use `Path(...)` with descriptions and examples for documentation
- Validate path parameters with type hints

### Request Body Handling
```python
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created"),
    db: Session = Depends(get_db)):
```
- Use Pydantic models for request validation
- Use `Body(...)` with descriptions for documentation

### Error Handling
```python
if db_book is None:
    raise HTTPException(status_code=404, detail="Book not found")
```
- **Always check for None** before operating on database results
- **Use HTTPException** with appropriate status codes (404 for not found, 400 for bad request)
- **Provide clear error messages** in the `detail` field

### Database Operations Pattern
```python
# Create
db_book = Book(**book.model_dump())
db.add(db_book)
db.commit()
db.refresh(db_book)
return BookInfo(**db_book.__dict__)

# Read
db_book = db.query(Book).filter(Book.id == book_id).first()

# Update
for key, value in book.model_dump().items():
    setattr(db_book, key, value)
db.commit()
db.refresh(db_book)

# Delete
db.delete(db_book)
db.commit()
```
- **Always commit** after modifications
- **Always refresh** after commit to get updated values
- **Convert to DTO** before returning (e.g., `BookInfo(**db_book.__dict__)`)

## Frontend JavaScript Patterns

### State Management
```javascript
const state = {
    books: [],
    filteredBooks: [],
    filters: { search: '', category: 'all', favorite: false },
    sort: { by: 'title', ascending: true },
    pagination: { page: 1, limit: 12, hasMore: false }
};
```
- **Centralized state object** for managing application data
- **Separate filtered data** from source data for efficient rendering
- **Track UI state** (filters, sort, pagination) in state object

### API Communication
```javascript
async function fetchBooks() {
    try {
        const response = await fetch(API_URL);
        if (!response.ok) {
            throw new Error('Failed to fetch books');
        }
        state.books = await response.json();
        displayBooks(state.filteredBooks);
    } catch (error) {
        console.error('Error fetching books:', error);
        showNotification('Error fetching books', 'error');
    }
}
```
- **Always use async/await** for API calls
- **Always check response.ok** before parsing JSON
- **Always use try/catch** for error handling
- **Show user feedback** via notifications for errors
- **Update state** before triggering UI updates

### Event Handling
```javascript
document.addEventListener('DOMContentLoaded', fetchBooks);
bookForm.addEventListener('submit', addBook);
searchInput.addEventListener('input', debounce(() => {
    state.filters.search = searchInput.value.trim().toLowerCase();
    applyFiltersAndSort();
}, 300));
```
- **Wait for DOMContentLoaded** before initializing
- **Prevent default** on form submissions with `e.preventDefault()`
- **Debounce input events** to avoid excessive processing
- **Normalize input** (trim, toLowerCase) before filtering

### DOM Manipulation
```javascript
const bookCard = document.createElement('div');
bookCard.classList.add('book-card');
bookCard.dataset.id = book.id;
bookCard.innerHTML = `...`;
booksList.appendChild(bookCard);
```
- **Use template literals** for HTML generation
- **Store IDs in data attributes** for later reference
- **Add event listeners** after creating elements
- **Clear containers** before re-rendering: `booksList.innerHTML = ''`

### User Feedback Pattern
```javascript
function showNotification(message, type) {
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    const notification = document.createElement('div');
    notification.classList.add('notification', type);
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => {
        notification.classList.add('hide');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}
```
- **Remove existing notifications** before showing new ones
- **Use CSS classes** for styling (success, error)
- **Auto-dismiss** after 3 seconds
- **Animate removal** with CSS transitions

## Testing Patterns

### Pytest API Testing
```python
from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
```
- **Use TestClient** for testing FastAPI endpoints
- **Mock database sessions** via fixtures (conftest.py)
- **Test both success and error cases** (e.g., `test_read_book_success`, `test_read_book_not_found`)
- **Assert status codes** and response data
- **Use descriptive test names** that explain what is being tested

### Test Organization
- **One test file per module** (e.g., `test_books.py` for `books.py`)
- **Group related tests** by functionality
- **Use fixtures** for common setup (database mocking, test data)
- **Test edge cases**: not found (404), validation errors, empty results

## Database Patterns

### SQLAlchemy Model Definition
```python
from sqlalchemy import Column, Integer, String, Boolean
from .database import Base

class Book(Base):
    __tablename__ = "books"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    author = Column(String, nullable=False)
    pages = Column(Integer, nullable=False)
    category = Column(String, default="Fiction")
    favorite = Column(Boolean, default=False)
```
- **Inherit from Base** for all models
- **Set `__tablename__`** explicitly
- **Use appropriate column types** (Integer, String, Boolean)
- **Set nullable constraints** appropriately
- **Provide defaults** for optional fields

### Pydantic DTO Pattern
```python
from pydantic import BaseModel

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"

class BookInfo(BookCreate):
    id: int
    favorite: bool = False
```
- **Separate DTOs for input and output** (BookCreate vs BookInfo)
- **Inherit for shared fields** to avoid duplication
- **Provide defaults** for optional fields
- **Use type hints** for validation

### Database Session Management
```python
from sqlalchemy.orm import sessionmaker

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```
- **Use dependency injection** pattern with `yield`
- **Always close sessions** in finally block
- **Disable autocommit** for explicit transaction control

## Script Patterns

### Database Initialization Scripts
```python
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import get_db, engine, Base
from fastapi_demo.models import Book

def main():
    Base.metadata.create_all(bind=engine)
    db = next(get_db())
    # ... perform operations
    
if __name__ == "__main__":
    main()
```
- **Add parent directory to path** for imports
- **Import models early** to avoid circular imports
- **Create tables** before operations
- **Use `if __name__ == "__main__"`** guard

### Data Generation
- **Use random module** for generating test data
- **Provide variety** in generated data (categories, authors, titles)
- **Set realistic ranges** (e.g., pages between 100-1000)
- **Commit in batches** for efficiency

## Documentation Standards

### API Documentation
- **Always provide summary** for each endpoint
- **Write clear descriptions** explaining what the endpoint does
- **Document parameters** with descriptions and examples
- **Specify response models** for automatic schema generation

### Code Comments
- **Explain "why" not "what"**: Code should be self-explanatory, comments explain reasoning
- **Section headers**: Use comments to separate logical sections (e.g., `// DOM Elements`, `// Event Listeners`)
- **Function documentation**: Docstrings for Python functions, JSDoc-style comments for complex JavaScript functions

### README Documentation
- **Multiple setup methods**: Document Docker, Poetry, and venv approaches
- **Step-by-step instructions**: Clear numbered steps for each method
- **Include commands**: Show exact commands to run
- **Link to API docs**: Reference auto-generated documentation

## Common Idioms

### Python
- **Dictionary unpacking**: `Book(**book.model_dump())` for creating models from DTOs
- **List comprehensions**: `[BookInfo(**book.__dict__) for book in books]` for transformations
- **Context managers**: Use `with` for file operations (though not heavily used in this codebase)

### JavaScript
- **Spread operator**: `[...state.books]` for array copying
- **Destructuring**: Not heavily used, but available for object/array destructuring
- **Optional chaining**: Use `?.` for safe property access
- **Ternary operators**: `book.favorite ? 'active' : ''` for conditional values

## Frequently Used Annotations

### FastAPI
- `@router.get()`, `@router.post()`, `@router.put()`, `@router.delete()`, `@router.patch()` - HTTP method decorators
- `Depends()` - Dependency injection
- `Path()` - Path parameter validation
- `Body()` - Request body validation
- `HTTPException` - Error responses

### SQLAlchemy
- `Column()` - Define table columns
- `Integer`, `String`, `Boolean` - Column types
- `primary_key=True` - Primary key designation
- `index=True` - Create database index
- `nullable=False` - NOT NULL constraint
- `default=` - Default values

### Pydantic
- `BaseModel` - Base class for DTOs
- `model_dump()` - Convert model to dictionary
- Type hints for automatic validation

## Best Practices Summary

1. **Always validate input** using Pydantic models
2. **Always check for None** before database operations
3. **Always use try/catch** for API calls and error-prone operations
4. **Always provide user feedback** via notifications or error messages
5. **Always commit and refresh** after database modifications
6. **Always document endpoints** with summary, description, and response models
7. **Always use dependency injection** for database sessions
8. **Always separate concerns** (models, DTOs, routes, database)
9. **Always test both success and failure cases**
10. **Always use appropriate HTTP status codes** (200, 404, 400, etc.)
