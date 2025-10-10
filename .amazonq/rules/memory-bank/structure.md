# Books Database Service - Project Structure

## Directory Organization

### Core Application (`fastapi_demo/`)
Main application package containing the FastAPI backend.

- **`main.py`** - FastAPI application entry point, CORS configuration, static file serving
- **`models.py`** - SQLAlchemy ORM models (Book model with database schema)
- **`database.py`** - Database connection, session management, engine configuration
- **`dtos.py`** - Pydantic models for request/response validation and serialization
- **`routers/`** - API route handlers organized by resource
  - **`books.py`** - Books API endpoints (CRUD, search, filter, favorite toggle)
- **`static/`** - Frontend assets served by FastAPI
  - **`index.html`** - Single-page application UI
  - **`script.js`** - Frontend JavaScript for API interaction
  - **`styles.css`** - UI styling and responsive design

### Testing (`tests/` and `robot_tests_*/`)
Comprehensive test suites for API and UI validation.

- **`tests/`** - Pytest-based API tests
  - **`conftest.py`** - Pytest fixtures and test configuration
  - **`test_books.py`** - API endpoint tests with httpx TestClient
- **`robot_tests_claude_sonnet_4_5/`** - Robot Framework UI and API tests (production-ready)
  - **`books_ui.robot`** - UI test cases using Browser library
  - **`books_api.robot`** - API test cases using RequestsLibrary
  - **`resources/`** - Reusable keywords and configuration
    - **`common.resource`** - Shared variables and setup/teardown
    - **`ui_keywords.resource`** - UI interaction keywords
    - **`api_keywords.resource`** - API request keywords
- **`robot_tests_claude_sonnet_4/`** - Alternative Robot Framework tests (stub implementations)

### Database and Scripts (`data/` and `scripts/`)
Database storage and utility scripts.

- **`data/`** - SQLite database file storage
  - **`books.db`** - Persistent book data
- **`scripts/`** - Database management utilities
  - **`migrate_db.py`** - Database schema migration (adds favorite column)
  - **`generate_books.py`** - Sample data generation for testing
  - **`run_robot_tests.sh`** - Robot Framework test execution script

### Configuration and Deployment
Project configuration, dependencies, and containerization.

- **`pyproject.toml`** - Poetry dependency management and project metadata
- **`poetry.lock`** - Locked dependency versions
- **`requirements.txt`** - Pip-compatible dependency list
- **`server.py`** - Development server entry point
- **`Dockerfile`** - Container image definition
- **`docker-compose.yml`** - Multi-service orchestration with initialization
- **`pytest.ini`** - Pytest configuration
- **`.github/workflows/ci_tests.yaml`** - CI/CD pipeline configuration

### Documentation
- **`README.md`** - Project documentation and setup instructions
- **`CLAUDE.md`** - AI assistant context and guidelines
- **`TEST_COMPARISON.md`** - Comparison of Robot Framework test implementations
- **`LICENSE`** - MIT license

## Architectural Patterns

### Layered Architecture
- **Presentation Layer**: FastAPI routes and static HTML/JS frontend
- **Business Logic Layer**: Route handlers in `routers/books.py`
- **Data Access Layer**: SQLAlchemy ORM models and database session management
- **Data Layer**: SQLite database

### API Design
- RESTful resource-based endpoints (`/books/`, `/books/{id}`)
- HTTP method semantics (GET, POST, PUT, DELETE)
- JSON request/response format
- Pydantic validation for type safety
- Automatic OpenAPI documentation

### Frontend Architecture
- Single-page application (SPA) pattern
- Vanilla JavaScript with fetch API for backend communication
- Dynamic DOM manipulation for real-time updates
- Client-side filtering and pagination

### Testing Strategy
- **Unit/Integration Tests**: Pytest with FastAPI TestClient
- **UI Tests**: Robot Framework with Browser library (Playwright)
- **API Tests**: Robot Framework with RequestsLibrary
- **CI/CD**: GitHub Actions for automated testing

### Database Management
- SQLAlchemy ORM for database abstraction
- Migration scripts for schema evolution
- Seed data generation for development and testing
- SQLite for simplicity and portability

## Component Relationships

```
FastAPI App (main.py)
    ├── Serves Static Files (index.html, script.js, styles.css)
    ├── Includes Router (books.py)
    │   ├── Uses DTOs (dtos.py) for validation
    │   ├── Uses Models (models.py) for database operations
    │   └── Uses Database (database.py) for sessions
    └── Configured with CORS for frontend access

Database (books.db)
    ├── Managed by SQLAlchemy (models.py, database.py)
    ├── Initialized by migrate_db.py
    └── Populated by generate_books.py

Tests
    ├── Pytest (tests/) → Tests API directly
    └── Robot Framework (robot_tests_*/) → Tests API and UI through browser
```
