# Development Guidelines

## Code Quality Standards

### Python Code Formatting

**Import Organization**
- Standard library imports first
- Third-party imports second
- Local application imports last
- Use relative imports within packages (e.g., `from ..database import get_db`)
- Group imports logically and alphabetically within each section

**Type Hints**
- Use type hints for function parameters and return values
- Example: `def read_books(db: Session = Depends(get_db)) -> List[BookInfo]:`
- Import types from `typing` module: `List`, `Dict`, `Any`

**Docstrings**
- Use triple-quoted strings for module-level documentation
- Keep docstrings concise and descriptive
- Example: `"""Script to generate 100 sample books with various categories"""`

**Function Documentation**
- Use inline comments for complex logic
- Document function purpose with brief comments
- Example: `def generate_title(): """Generate a random book title"""`

### JavaScript Code Formatting

**Variable Declarations**
- Use `const` for constants and immutable references
- Use `let` for variables that will be reassigned
- Avoid `var` - not used in this codebase
- Group related constants together at the top of files

**Function Definitions**
- Use `async function` for asynchronous operations
- Use arrow functions for callbacks and event handlers
- Example: `async function fetchBooks() { ... }`
- Example: `searchInput.addEventListener('input', debounce(() => { ... }, 300))`

**Comments**
- Use single-line comments (`//`) for section headers and explanations
- Group related code with comment headers
- Example: `// DOM Elements`, `// API Base URL`, `// App State`

**String Formatting**
- Use template literals for string interpolation
- Example: `` `${API_URL}/${id}` ``
- Use single quotes for simple strings
- Use backticks for HTML template strings

## Structural Conventions

### FastAPI Application Structure

**Router Organization**
```python
router = APIRouter(
    prefix="/books",
    tags=["books"]
)
```
- Define routers with clear prefixes
- Use tags for API documentation grouping
- Keep related endpoints in the same router file

**Endpoint Definitions**
```python
@router.get("/", response_model=List[BookInfo],
         summary="Get all books",
         description="This endpoint retrieves all books from the database",
         response_description="A list of all books")
def read_books(db: Session = Depends(get_db)):
    ...
```
- Always specify `response_model` for type safety and documentation
- Include `summary` and `description` for API documentation
- Use dependency injection for database sessions: `db: Session = Depends(get_db)`
- Use descriptive function names that match HTTP verbs: `read_books`, `create_book`, `update_book`, `delete_book`

**Path Parameters**
```python
@router.get("/{book_id}", response_model=BookInfo)
def read_book(
    book_id: int = Path(..., description="The ID of the book to be retrieved", examples=1),
    db: Session = Depends(get_db)):
```
- Use `Path(...)` for path parameter validation and documentation
- Include descriptions and examples for better API docs

**Request Body Parameters**
```python
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created"),
    db: Session = Depends(get_db)):
```
- Use `Body(...)` for request body documentation
- Use Pydantic models for request validation

### Database Patterns

**ORM Model Conversion**
```python
return BookInfo(**db_book.__dict__)
```
- Convert SQLAlchemy models to Pydantic DTOs using `**model.__dict__`
- This pattern appears consistently across all endpoints

**Query Patterns**
```python
db_book = db.query(Book).filter(Book.id == book_id).first()
if db_book is None:
    raise HTTPException(status_code=404, detail="Book not found")
```
- Always check if query results are `None` before proceeding
- Raise `HTTPException` with appropriate status codes (404 for not found)
- Use descriptive error messages

**CRUD Operations**
```python
# Create
db_book = Book(**book.model_dump())
db.add(db_book)
db.commit()
db.refresh(db_book)

# Update
for key, value in book.model_dump().items():
    setattr(db_book, key, value)
db.commit()
db.refresh(db_book)

# Delete
db.delete(db_book)
db.commit()
```
- Use `model_dump()` to convert Pydantic models to dictionaries
- Always call `db.commit()` after modifications
- Use `db.refresh()` to get updated values from database
- Use `setattr()` for dynamic attribute updates

### Frontend JavaScript Patterns

**State Management**
```javascript
const state = {
    books: [],
    filteredBooks: [],
    filters: { search: '', category: 'all', favorite: false },
    sort: { by: 'title', ascending: true },
    pagination: { page: 1, limit: 12, hasMore: false }
};
```
- Use a centralized state object for application data
- Group related state properties into nested objects
- Initialize with sensible defaults

**API Communication**
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
- Always use `async/await` for asynchronous operations
- Wrap API calls in try-catch blocks
- Check `response.ok` before parsing JSON
- Show user-friendly error notifications
- Log errors to console for debugging

**Event Handling**
```javascript
document.addEventListener('DOMContentLoaded', fetchBooks);
bookForm.addEventListener('submit', addBook);
searchInput.addEventListener('input', debounce(() => {
    state.filters.search = searchInput.value.trim().toLowerCase();
    applyFiltersAndSort();
}, 300));
```
- Use `DOMContentLoaded` for initialization
- Prevent default form submission with `e.preventDefault()`
- Use debounce for input events to avoid excessive function calls
- Update state before triggering UI updates

**DOM Manipulation**
```javascript
const bookCard = document.createElement('div');
bookCard.classList.add('book-card');
bookCard.dataset.id = book.id;
bookCard.innerHTML = `...`;
booksList.appendChild(bookCard);
```
- Create elements with `document.createElement()`
- Use `classList.add()` for adding CSS classes
- Use `dataset` for storing data attributes
- Use template literals for complex HTML structures
- Append elements to DOM after full construction

## Testing Patterns

### Pytest Testing

**Test Function Naming**
```python
def test_create_book(mock_db_session):
def test_read_book_success(mock_db_session):
def test_read_book_not_found(mock_db_session):
```
- Prefix all test functions with `test_`
- Use descriptive names that indicate what is being tested
- Include expected outcome in name (e.g., `_success`, `_not_found`)

**Test Structure**
```python
def test_read_book_success(mock_db_session):
    # Arrange
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(...)
    
    # Act
    response = client.get("/books/1")
    
    # Assert
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
```
- Follow Arrange-Act-Assert pattern
- Mock database sessions using fixtures
- Use `TestClient` for API endpoint testing
- Assert both status codes and response data

**Mocking Database Operations**
```python
mock_db_session.query.return_value.filter.return_value.first.return_value = Book(...)
```
- Chain mock return values to simulate SQLAlchemy query patterns
- Return `None` to test not-found scenarios
- Use fixtures for consistent mock setup

### Robot Framework Testing

**Test Organization**
- Separate API tests and UI tests into different files
- Use resource files for shared keywords and variables
- Group related keywords by functionality (api_keywords, ui_keywords, common)

## Common Code Idioms

### Python Idioms

**Dictionary Unpacking**
```python
db_book = Book(**book.model_dump())
return BookInfo(**db_book.__dict__)
```
- Use `**` operator to unpack dictionaries as keyword arguments
- Common pattern for converting between models

**List Comprehensions**
```python
return [BookInfo(**book.__dict__) for book in books]
```
- Use list comprehensions for transforming collections
- Keep comprehensions simple and readable

**Path Manipulation**
```python
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
```
- Use `os.path` for cross-platform path operations
- Add parent directories to path for imports in scripts

**Random Data Generation**
```python
favorite=random.random() < 0.2  # About 20% of books set as favorites
```
- Use `random.random()` with comparison for probability-based selection
- Include comments explaining probability thresholds

### JavaScript Idioms

**Array Spread Operator**
```javascript
state.filteredBooks = [...state.books];
```
- Use spread operator to create shallow copies of arrays
- Prevents unintended mutations of original data

**Ternary Operators**
```javascript
sortDirectionBtn.querySelector('i').className = state.sort.ascending 
    ? 'fas fa-sort-up' 
    : 'fas fa-sort-down';
```
- Use ternary operators for conditional assignments
- Format multi-line for readability

**Template Literals**
```javascript
bookCard.innerHTML = `
    <h3 class="book-title">${book.title}</h3>
    <p class="book-author">by ${book.author}</p>
`;
```
- Use template literals for HTML generation
- Escape user data appropriately (framework handles this)

**Array Methods**
```javascript
state.filteredBooks = state.books.filter(book => {
    return matchesSearch && matchesCategory && matchesFavorite;
});

state.filteredBooks.sort((a, b) => {
    if (valueA < valueB) return state.sort.ascending ? -1 : 1;
    if (valueA > valueB) return state.sort.ascending ? 1 : -1;
    return 0;
});
```
- Use `filter()` for filtering arrays
- Use `sort()` with comparison function for custom sorting
- Chain array methods when appropriate

**Optional Chaining and Nullish Coalescing**
```javascript
const existingNotification = document.querySelector('.notification');
if (existingNotification) {
    existingNotification.remove();
}
```
- Check for element existence before manipulation
- Use explicit null checks for clarity

## API Usage Patterns

### FastAPI Dependency Injection

**Database Session Management**
```python
from ..database import get_db

def read_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return books
```
- Import `get_db` from database module
- Use `Depends(get_db)` for automatic session management
- Session is automatically closed after request

### Pydantic Model Usage

**Model Conversion**
```python
# Request validation
book: BookCreate = Body(...)

# Database creation
db_book = Book(**book.model_dump())

# Response serialization
return BookInfo(**db_book.__dict__)
```
- Use `BookCreate` for input validation
- Use `BookInfo` for response serialization
- Use `model_dump()` to convert Pydantic to dict

### HTTP Status Codes

**Standard Status Codes**
- 200: Successful GET, PUT, PATCH, DELETE
- 404: Resource not found
- 422: Validation error (automatic with Pydantic)

**Error Handling**
```python
if db_book is None:
    raise HTTPException(status_code=404, detail="Book not found")
```
- Use `HTTPException` for all API errors
- Provide descriptive error messages in `detail`

## MCP Server Patterns

### JSON-RPC Protocol

**Request Handling**
```python
def handle_request(request: Dict[str, Any]) -> Dict[str, Any]:
    method = request.get("method")
    
    if method == "initialize":
        return {"jsonrpc": "2.0", "id": request.get("id"), "result": {...}}
    elif method == "tools/list":
        return {"jsonrpc": "2.0", "id": request.get("id"), "result": {...}}
    elif method == "tools/call":
        params = request.get("params", {})
        return {"jsonrpc": "2.0", "id": request.get("id"), "result": {...}}
```
- Use if-elif chain for method routing
- Always include `jsonrpc` version and request `id` in responses
- Return structured responses with `result` or `error` keys

**Tool Definitions**
```python
{
    "name": "calculate",
    "description": "Perform basic arithmetic calculations",
    "inputSchema": {
        "type": "object",
        "properties": {
            "expression": {
                "type": "string",
                "description": "Mathematical expression to evaluate"
            }
        },
        "required": ["expression"]
    }
}
```
- Define clear tool names and descriptions
- Use JSON Schema for input validation
- Specify required parameters

**STDIO Communication**
```python
def main():
    for line in sys.stdin:
        try:
            request = json.loads(line.strip())
            response = handle_request(request)
            print(json.dumps(response))
            sys.stdout.flush()
        except Exception as e:
            error_response = {...}
            print(json.dumps(error_response))
            sys.stdout.flush()
```
- Read JSON-RPC requests from stdin line by line
- Write responses to stdout with `sys.stdout.flush()`
- Handle parsing errors gracefully with error responses

## Frequently Used Annotations

### FastAPI Decorators
- `@router.get()` - GET endpoint
- `@router.post()` - POST endpoint
- `@router.put()` - PUT endpoint
- `@router.patch()` - PATCH endpoint
- `@router.delete()` - DELETE endpoint

### FastAPI Parameters
- `Depends()` - Dependency injection
- `Path()` - Path parameter validation
- `Body()` - Request body documentation
- `HTTPException()` - Error responses

### SQLAlchemy
- `db.query(Model)` - Start query
- `.filter()` - Add WHERE clause
- `.all()` - Get all results
- `.first()` - Get first result or None
- `db.add()` - Add to session
- `db.commit()` - Commit transaction
- `db.refresh()` - Refresh from database
- `db.delete()` - Delete from database

## Best Practices Summary

1. **Always validate input** - Use Pydantic models for request validation
2. **Handle errors gracefully** - Use try-catch blocks and return meaningful error messages
3. **Check for None** - Always verify database query results before use
4. **Use dependency injection** - Leverage FastAPI's Depends() for clean code
5. **Document APIs** - Include summary, description, and examples in endpoint definitions
6. **Separate concerns** - Keep routers, models, DTOs, and database logic in separate files
7. **Test thoroughly** - Write tests for both success and failure scenarios
8. **Use type hints** - Improve code clarity and enable better IDE support
9. **Manage state centrally** - Use a single state object in frontend applications
10. **Debounce user input** - Prevent excessive API calls from search inputs
