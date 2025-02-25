# CLAUDE.md - Agent Guidelines

## Commands
- Install deps: `poetry install`
- Run server: `poetry run dev-server`
- Run server (Docker): `docker-compose up -d`
- Activate venv: `poetry shell`
- Run all tests: `poetry run pytest`
- Run single test: `poetry run pytest tests/test_books.py::test_create_book -v`
- Run verbose tests: `poetry run pytest -v` or `poetry run pytest -vv`
- Initialize database: `poetry run python scripts/migrate_db.py && poetry run python scripts/generate_books.py`
- Check API docs: Visit http://localhost:8000/docs
- UI tests: 
  - Init Browser lib: `poetry run python -m Browser.entry init`
  - Run Robot tests: `poetry run robot --outputdir robot_results robot_tests/`
  - Run with script: `./scripts/run_robot_tests.sh`
  - Tests handle Docker automatically: start with docker-compose up and clean with docker-compose down

## Code Style
- **Imports**: stdlib → third-party → local, explicit imports with full path statements
- **Types**: Use type hints throughout, Pydantic models for validation and DTOs
- **Naming**: snake_case (variables/functions), PascalCase (classes)
- **Error handling**: HTTP exceptions with appropriate status codes for REST APIs
- **API design**: Router-based organization with explicit documentation per endpoint
- **Testing**: Pytest with TestClient, mocks in unittest.mock
- **Project structure**: Separated models (ORM)/DTOs, resource-based routers
- **DB access**: SQLAlchemy for models, dependency injection for database sessions
- **Docker**: Python 3.12, uvicorn for deployment, FastAPI for API framework