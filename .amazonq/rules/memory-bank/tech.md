# Books Database Service - Technology Stack

## Programming Languages
- **Python 3.12** - Primary backend language
- **JavaScript (ES6+)** - Frontend client-side scripting
- **HTML5** - UI markup
- **CSS3** - Styling and responsive design
- **SQL** - Database queries (via SQLAlchemy ORM)

## Backend Framework and Libraries

### Core Framework
- **FastAPI 0.115.11** - Modern async web framework with automatic API documentation
- **Uvicorn 0.29.0** - ASGI server for running FastAPI applications
- **Pydantic 2.6.4** - Data validation and settings management using Python type annotations

### Database
- **SQLAlchemy 2.0.29** - SQL toolkit and ORM for database operations
- **SQLite** - Lightweight embedded database (file-based at `data/books.db`)

### Testing
- **Pytest 8.1.1** - Python testing framework for API tests
- **httpx 0.27.0** - HTTP client for testing FastAPI applications
- **Robot Framework 6.1.1** - Keyword-driven test automation framework
- **Robot Framework Browser 17.5.2** - Browser automation library using Playwright

## Frontend Technologies
- **Vanilla JavaScript** - No framework dependencies, direct DOM manipulation
- **Fetch API** - Modern HTTP client for API requests
- **CSS Grid/Flexbox** - Responsive layout system

## Development Tools

### Dependency Management
- **Poetry** - Primary dependency management and packaging tool
- **pip** - Alternative package installer (via requirements.txt)

### Containerization
- **Docker** - Container runtime for application packaging
- **Docker Compose** - Multi-container orchestration

### CI/CD
- **GitHub Actions** - Automated testing and continuous integration

## Development Commands

### Using Poetry (Recommended)

**Install Dependencies:**
```bash
poetry install
```

**Run Development Server:**
```bash
poetry run dev-server
# or
poetry run uvicorn fastapi_demo.main:app --reload
```

**Run API Tests:**
```bash
poetry run pytest                                    # All tests
poetry run pytest -v                                 # Verbose output
poetry run pytest tests/test_books.py::test_name -v # Specific test
```

**Run Robot Framework Tests:**
```bash
# Initialize Browser library (first time only)
poetry run python -m Browser.entry init

# Run all UI tests
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4_5/

# Run specific test
poetry run robot --outputdir robot_results -t "Test Name" robot_tests_claude_sonnet_4_5/
```

**Database Management:**
```bash
python scripts/migrate_db.py      # Run migrations
python scripts/generate_books.py  # Generate sample data
```

### Using Docker (Production)

**Start Application:**
```bash
docker-compose up -d              # Start in background
docker-compose up                 # Start with logs
```

**Stop Application:**
```bash
docker-compose down               # Stop and remove containers
docker-compose down -v            # Also remove volumes
```

**View Logs:**
```bash
docker-compose logs -f            # Follow logs
docker-compose logs books-service # Service-specific logs
```

### Using Python Virtual Environment

**Setup:**
```bash
python -m venv .venv
source .venv/bin/activate         # Linux/macOS
.venv\Scripts\activate            # Windows
pip install -r requirements.txt
```

**Run:**
```bash
python server.py
```

## API Documentation
- **Swagger UI**: http://localhost:8000/docs (interactive API documentation)
- **ReDoc**: http://localhost:8000/redoc (alternative API documentation)
- **OpenAPI JSON**: http://localhost:8000/openapi.json (machine-readable schema)

## Application URLs
- **Frontend**: http://localhost:8000
- **API Base**: http://localhost:8000/books/
- **Health Check**: http://localhost:8000/books/ (GET request)

## Build System
- **Poetry** for dependency resolution and virtual environment management
- **Poetry scripts** defined in pyproject.toml for common tasks
- **Docker multi-stage builds** for optimized container images

## Environment Variables
- **DATABASE_URL**: SQLite database connection string (default: `sqlite:///data/books.db`)
- Configured in docker-compose.yml for containerized deployments

## Python Version Requirements
- **Minimum**: Python 3.12
- **Specified in**: pyproject.toml (`python = "^3.12"`)
