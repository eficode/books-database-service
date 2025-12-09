# Project Structure

## Directory Organization

```
books-database-service/
├── fastapi_demo/          # Main application package
│   ├── routers/           # API route handlers
│   ├── static/            # Frontend assets (HTML, CSS, JS)
│   ├── database.py        # Database configuration and session management
│   ├── dtos.py            # Data Transfer Objects (Pydantic models)
│   ├── main.py            # FastAPI application setup
│   └── models.py          # SQLAlchemy ORM models
├── tests/                 # Pytest unit and integration tests
├── robot_tests_claude_sonnet_4/     # Robot Framework UI tests (v4)
├── robot_tests_claude_sonnet_4_5/   # Robot Framework UI tests (v4.5)
├── scripts/               # Utility scripts for database and data generation
├── data/                  # SQLite database file
├── Amazon_Q/              # Amazon Q MCP server integrations
│   ├── calculator-mcp/    # Calculator MCP server example
│   └── RobotFramework-MCP-server/  # Robot Framework MCP integration
├── robot_results/         # Test execution results and reports
└── .amazonq/              # Amazon Q configuration and rules
```

## Core Components

### Application Layer (`fastapi_demo/`)

**main.py** - Application entry point
- Initializes FastAPI application with metadata
- Creates database tables on startup
- Registers API routers
- Mounts static file serving
- Serves the frontend at root path

**routers/books.py** - Books API endpoints
- GET `/api/books` - List books with filtering, sorting, pagination
- POST `/api/books` - Create new book
- GET `/api/books/{book_id}` - Get single book
- PUT `/api/books/{book_id}` - Update book
- DELETE `/api/books/{book_id}` - Delete book

**database.py** - Database configuration
- SQLAlchemy engine setup for SQLite
- Session factory configuration
- Database dependency injection for FastAPI

**models.py** - ORM models
- `Book` model with fields: id, title, author, category, publication_year, description
- SQLAlchemy table definitions

**dtos.py** - Request/response schemas
- `BookCreate` - Validation for creating books
- `BookUpdate` - Validation for updating books
- `BookResponse` - Response serialization
- Pydantic models for type safety and validation

**static/** - Frontend files
- `index.html` - Single-page application structure
- `script.js` - Client-side logic for API interaction
- `styles.css` - Responsive styling

### Testing Layer

**tests/** - Pytest tests
- `conftest.py` - Test fixtures and configuration
- `test_books.py` - API endpoint tests with httpx TestClient

**robot_tests_claude_sonnet_4/** - Robot Framework tests (version 4)
- `books_api.robot` - API test cases
- `books_ui.robot` - Browser-based UI test cases
- `resources/` - Shared keywords and variables

**robot_tests_claude_sonnet_4_5/** - Robot Framework tests (version 4.5)
- Enhanced test suite with improved keywords
- `resources/api_keywords.resource` - API testing keywords
- `resources/ui_keywords.resource` - UI testing keywords
- `resources/common.resource` - Shared configuration

### Infrastructure

**Docker Configuration**
- `Dockerfile` - Application container image
- `docker-compose.yml` - Multi-container orchestration
- `.dockerignore` - Build context optimization

**CI/CD**
- `.github/workflows/ci_tests.yaml` - GitHub Actions pipeline for automated testing

**Amazon Q Integration**
- `.amazonq/agents/default.json` - Agent configuration
- `Amazon_Q/RobotFramework-MCP-server/` - MCP server for running Robot Framework tests through Amazon Q
- Persistent Docker container setup for fast test execution

### Scripts and Utilities

**scripts/**
- `migrate_db.py` - Initialize database schema
- `generate_books.py` - Populate database with sample data
- `run_robot_tests.sh` - Execute Robot Framework test suite

**server.py** - Development server launcher
- Uvicorn server configuration
- Hot-reload enabled for development

## Architectural Patterns

### Layered Architecture
1. **Presentation Layer**: FastAPI routers and static frontend
2. **Business Logic Layer**: Service logic in routers (lightweight for this demo)
3. **Data Access Layer**: SQLAlchemy ORM models and database session management

### Dependency Injection
- Database sessions injected via FastAPI's `Depends()`
- Promotes testability and loose coupling

### DTO Pattern
- Separation between API contracts (DTOs) and database models
- Pydantic for request validation and response serialization

### Repository Pattern (Implicit)
- Database operations encapsulated in router functions
- Could be extracted to dedicated repository classes for larger applications

### Test Isolation
- Pytest fixtures for test database setup
- Robot Framework tests use Docker for environment isolation
- Separate test suites for API and UI testing

## Component Relationships

```
Frontend (static/) ←→ FastAPI (main.py) ←→ Routers (books.py)
                                              ↓
                                         DTOs (dtos.py)
                                              ↓
                                         Models (models.py)
                                              ↓
                                         Database (database.py)
                                              ↓
                                         SQLite (data/books.db)
```

## Configuration Files

- `pyproject.toml` - Poetry dependency management and project metadata
- `requirements.txt` - Pip-compatible dependency list
- `pytest.ini` - Pytest configuration
- `.amazonq/rules/*.yaml` - Amazon Q context and standards
