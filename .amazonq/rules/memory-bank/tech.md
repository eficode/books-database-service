# Technology Stack

## Programming Languages

### Python 3.12+
- Primary backend language
- Modern Python features and type hints
- Async/await support for FastAPI

### JavaScript (ES6+)
- Frontend implementation with vanilla JavaScript
- No framework dependencies (React, Vue, etc.)
- Modern DOM manipulation and fetch API

### HTML5 & CSS3
- Semantic HTML structure
- Responsive CSS with flexbox and grid
- Mobile-first design approach

## Backend Framework & Libraries

### FastAPI 0.115.11+
- Modern, high-performance web framework
- Automatic OpenAPI documentation generation
- Built-in request validation with Pydantic
- Async support for high concurrency

### Pydantic 2.6.4+
- Data validation using Python type annotations
- Automatic JSON schema generation
- DTO (Data Transfer Object) definitions

### SQLAlchemy 2.0.29+
- SQL toolkit and ORM
- Database abstraction layer
- Migration support
- Session management

### Uvicorn 0.29.0+
- ASGI server for FastAPI
- Hot-reload for development
- Production-ready performance

## Database

### SQLite
- File-based relational database (`data/books.db`)
- Zero configuration required
- Suitable for development and small deployments
- Easy to backup and version control

## Testing Frameworks

### Pytest 8.1.1+
- Unit and integration testing for API
- Fixture-based test setup
- httpx TestClient for API testing
- Async test support

### Robot Framework 6.1.1+
- Keyword-driven test automation
- Human-readable test syntax
- Browser automation with robotframework-browser 17.5.2+
- API testing capabilities

### HTTPX 0.27.0+
- Modern HTTP client for Python
- Async support
- Used in pytest tests via TestClient

## Development Tools

### Poetry
- Dependency management
- Virtual environment handling
- Script definitions in `pyproject.toml`
- Lock file for reproducible builds

### Docker & Docker Compose
- Application containerization
- Multi-container orchestration
- Consistent development and production environments
- Network isolation for testing

## Build System

### Poetry Core
- Build backend specified in `pyproject.toml`
- Package building and distribution
- Dependency resolution

## Development Commands

### Installation

**Using Poetry (Recommended)**
```bash
poetry install                    # Install all dependencies
poetry install --with test        # Install with test dependencies
```

**Using pip**
```bash
pip install -r requirements.txt   # Install from requirements file
```

### Running the Application

**Development Server**
```bash
poetry run dev-server             # Run with Poetry script
python server.py                  # Direct Python execution
uvicorn fastapi_demo.main:app --reload  # Direct uvicorn
```

**Docker**
```bash
docker-compose up -d              # Start in detached mode
docker-compose down               # Stop and remove containers
docker-compose logs -f            # Follow logs
```

### Testing

**API Tests (Pytest)**
```bash
poetry run pytest                 # Run all tests
poetry run pytest -v              # Verbose output
poetry run pytest tests/test_books.py::test_create_book  # Specific test
poetry run pytest --cov           # With coverage report
```

**UI Tests (Robot Framework)**
```bash
# Initialize Browser library (first time only)
poetry run python -m Browser.entry init

# Run all Robot tests
poetry run robot --outputdir robot_results robot_tests/

# Run specific test
poetry run robot --outputdir robot_results -t "User Can Open Books UI" robot_tests/

# Using script
./scripts/run_robot_tests.sh
```

### Database Management

```bash
python scripts/migrate_db.py      # Initialize database schema
python scripts/generate_books.py  # Generate sample data
```

### Amazon Q MCP Integration

**Robot Framework MCP Server**
```bash
cd Amazon_Q/RobotFramework-MCP-server
./setup.sh                        # Build Docker image
./start-container.sh              # Start persistent container
```

## CI/CD

### GitHub Actions
- Workflow file: `.github/workflows/ci_tests.yaml`
- Automated testing on push/pull request
- Python version matrix testing
- Test result reporting

## Configuration Files

- `pyproject.toml` - Poetry configuration, dependencies, scripts
- `requirements.txt` - Pip-compatible dependency list
- `pytest.ini` - Pytest configuration and test discovery
- `docker-compose.yml` - Multi-container Docker setup
- `Dockerfile` - Application container definition
- `.dockerignore` - Docker build context exclusions
- `.gitignore` - Git version control exclusions

## Environment Variables

### Application
- `HOST` - Server host (default: 127.0.0.1)
- `PORT` - Server port (default: 8000)

### Robot Framework MCP
- `ROBOT_OUTPUT_DIR` - Test results directory (default: /tmp/results)
- `RF_TESTS_DIR` - Test files location (default: /tests)
- `BROWSER` - Browser type (default: chromium)
- `HEADLESS` - Headless mode (default: true)

## API Documentation

- **Interactive Docs**: http://localhost:8000/docs (Swagger UI)
- **ReDoc**: http://localhost:8000/redoc (Alternative documentation)
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## Browser Support

### Frontend
- Modern browsers with ES6+ support
- Chrome, Firefox, Safari, Edge (latest versions)
- Mobile browsers (responsive design)

### Robot Framework Tests
- Chromium (default)
- Firefox
- WebKit
- Configurable via BROWSER environment variable
