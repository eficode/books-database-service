# CLAUDE.md - Agent Guidelines

## Commands
- Install deps: `poetry install`
- Run server: `poetry run dev-server`
- Activate venv: `poetry shell`
- Run all tests: `poetry run pytest`
- Run single test: `poetry run pytest tests/test_books.py::test_create_book -v`
- Run verbose tests: `poetry run pytest -v` or `poetry run pytest -vv`

## Code Style
- **Imports**: stdlib → third-party → local, explicit imports
- **Types**: Use type hints throughout, Pydantic models for validation
- **Naming**: snake_case (variables/functions), PascalCase (classes)
- **Error handling**: HTTP exceptions with appropriate status codes
- **API design**: Router-based organization with explicit documentation
- **Testing**: Pytest with TestClient, mocks in unittest.mock
- **Project structure**: Separated models/DTOs, resource-based routers
- **DB access**: SQLAlchemy for models, dependency injection for sessions