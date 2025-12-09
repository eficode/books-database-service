# Robot Framework Acceptance Tests

This directory contains Robot Framework acceptance tests for the Books Database Service, written in Gherkin syntax.

## Structure

```
robot_tests_claude_sonnet_4/
├── books_ui.robot              # UI acceptance tests
├── books_api.robot             # API acceptance tests
└── resources/
    ├── common.resource         # Common variables and keywords
    ├── ui_keywords.resource    # UI-specific keywords
    └── api_keywords.resource   # API-specific keywords
```

## Test Organization

### UI Tests (books_ui.robot)
- User Can Open Books UI
- User Can Add A New Book Through UI
- User Can Search For Books
- User Can Filter Books By Category
- User Can Sort Books By Title
- User Can Toggle Sort Direction
- User Can Filter Favorite Books

### API Tests (books_api.robot)
- User Can Retrieve All Books Via API
- User Can Create A New Book Via API
- User Can Retrieve A Specific Book Via API
- User Can Update An Existing Book Via API
- User Can Delete A Book Via API
- User Can Toggle Book Favorite Status Via API
- API Returns 404 For Non-Existent Book

## Running Tests

### Prerequisites

1. Install Robot Framework and dependencies:
```bash
poetry install
```

2. Initialize Browser library (first time only):
```bash
poetry run python -m Browser.entry init
```

### Run All Tests

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4/
```

### Run UI Tests Only

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4/books_ui.robot
```

### Run API Tests Only

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4/books_api.robot
```

### Run Tests by Tag

```bash
# Run smoke tests
poetry run robot --outputdir robot_results --include smoke robot_tests_claude_sonnet_4/

# Run CRUD tests
poetry run robot --outputdir robot_results --include crud robot_tests_claude_sonnet_4/

# Run UI tests only
poetry run robot --outputdir robot_results --include ui robot_tests_claude_sonnet_4/

# Run API tests only
poetry run robot --outputdir robot_results --include api robot_tests_claude_sonnet_4/
```

### Run Specific Test

```bash
poetry run robot --outputdir robot_results -t "User Can Open Books UI" robot_tests_claude_sonnet_4/
```

## Test Design Principles

### Gherkin Syntax
All test cases follow the Given-When-Then structure:
- **Given**: Setup and preconditions
- **When**: Actions performed
- **Then**: Expected outcomes

### Tags
- `ui`: UI tests
- `api`: API tests
- `smoke`: Critical smoke tests
- `crud`: Create/Read/Update/Delete operations
- `search`: Search functionality
- `filter`: Filter functionality
- `sort`: Sort functionality
- `favorite`: Favorite functionality
- `error`: Error handling tests

## Configuration

Variables can be customized in `resources/common.resource`:
- `BASE_URL`: Application base URL (default: http://localhost:8000)
- `BROWSER_TYPE`: Browser to use (default: chromium)
- `HEADLESS`: Run browser in headless mode (default: True)
- `TIMEOUT`: Default timeout for operations (default: 10s)

## Docker Integration

Tests automatically handle Docker environment:
- Suite setup starts Docker containers
- Suite teardown stops and cleans up containers
- No manual Docker management required