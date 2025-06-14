# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Install deps: `poetry install`
- Run server: `poetry run dev-server`
- Run server (Docker): `docker compose up -d`
- Build the Docker containers: `docker compose build` 
- Activate venv: `poetry shell`
- Run all tests: `poetry run pytest`
- Run single test: `poetry run pytest tests/test_books.py::test_create_book -v`
- Run specific test class: `poetry run pytest tests/test_books.py::TestBooksRouter -v`
- Run verbose tests: `poetry run pytest -v` or `poetry run pytest -vv`
- Initialize database: `poetry run python scripts/migrate_db.py && poetry run python scripts/generate_books.py`
- Check API docs: Visit http://localhost:8000/docs
- UI tests: 
  - Init Browser lib: `poetry run python -m Browser.entry init`
  - Run Robot tests: `poetry run robot --outputdir robot_results robot_tests/`
  - Run specific UI test: `poetry run robot --outputdir robot_results -t "User Can Open Books UI" robot_tests/`
  - Run with script: `./scripts/run_robot_tests.sh`
  - Tests handle Docker automatically: start with docker-compose up and clean with docker-compose down

## Architecture Overview

### API Structure
- **FastAPI Framework**: Modern Python web framework for building APIs
- **Layered Architecture**:
  - **Models** (`models.py`): SQLAlchemy ORM models defining database schema
  - **DTOs** (`dtos.py`): Pydantic models for request/response validation
  - **Routers** (`routers/books.py`, `routers/basket.py`): API endpoints organized by resource
  - **Database** (`database.py`): SQLAlchemy session management and connection setup
  - **Main** (`main.py`): FastAPI app configuration and initialization
  - **MCP Server** (`mcp_server.py`): Integration with Brave Search API for Claude MCP

### Database
- **SQLite**: Lightweight database with SQLAlchemy ORM
- **Connection management**: Dependency injection pattern for database sessions
- **Migration scripts**: Both automated in Docker and manual scripts in `scripts/`

### Frontend
- **Static files**: HTML, CSS, and JavaScript in `fastapi_demo/static/`
- **Single Page Application**: Client-side rendering for book management
- **Features**: Sorting, filtering, CRUD operations for books, shopping basket, favorites

### Testing
- **API Tests**: Pytest with TestClient for FastAPI endpoints
- **UI Tests**: Robot Framework for end-to-end browser testing
- **Test fixtures**: Mocked database sessions in `tests/conftest.py`
- **Docker Integration**: Robot tests manage Docker containers automatically

## Code Style
- **Imports**: stdlib → third-party → local, explicit imports with full path statements
- **Types**: Use type hints throughout, Pydantic models for validation and DTOs
- **Naming**: snake_case (variables/functions), PascalCase (classes)
- **Error handling**: HTTP exceptions with appropriate status codes for REST APIs
- **API design**: Router-based organization with explicit documentation per endpoint
- **Testing**: Pytest with TestClient, mocks in unittest.mock, BDD style for Robot tests
- **Project structure**: Separated models (ORM)/DTOs, resource-based routers
- **DB access**: SQLAlchemy for models, dependency injection for database sessions
- **Docker**: Python 3.12, uvicorn for deployment, FastAPI for API framework

## Working with the Codebase
- **Adding new endpoints**: Create or update router files in `fastapi_demo/routers/`
- **Database changes**: Update models in `models.py` and corresponding DTOs in `dtos.py`
- **UI changes**: Modify files in `fastapi_demo/static/`
- **Docker workflow**: Use `docker-compose up -d` for development with automatic DB setup
- **Testing approach**: Create API tests with pytest and UI tests with Robot Framework