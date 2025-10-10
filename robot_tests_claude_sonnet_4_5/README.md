# Robot Framework Acceptance Tests

This directory contains Robot Framework acceptance tests for the Books Database Service, written in Gherkin syntax.

## Structure

```
robot_tests_claude_sonnet_4_5/
├── books_ui.robot              # UI acceptance tests
├── books_api.robot             # API acceptance tests
└── resources/
    ├── common.resource         # Common variables and keywords
    ├── ui_keywords.resource    # UI-specific keywords
    └── api_keywords.resource   # API-specific keywords
```

## Test Organization

### UI Tests (books_ui.robot)
- User Can Add A New Book
- User Can Edit An Existing Book
- User Can Delete A Book
- User Can Mark Book As Favorite
- User Can Search For Books
- User Can Filter Books By Category
- User Can Filter Favorite Books

### API Tests (books_api.robot)
- API Can Create A New Book
- API Can Retrieve All Books
- API Can Retrieve A Book By ID
- API Can Update A Book
- API Can Delete A Book
- API Can Toggle Book Favorite Status
- API Returns 404 For Non-Existent Book
- API Validates Required Fields

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

3. Start the application:
```bash
docker-compose up -d
```

### Run All Tests

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4_5/
```

### Run UI Tests Only

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4_5/books_ui.robot
```

### Run API Tests Only

```bash
poetry run robot --outputdir robot_results robot_tests_claude_sonnet_4_5/books_api.robot
```

### Run Tests by Tag

```bash
# Run smoke tests
poetry run robot --outputdir robot_results --include smoke robot_tests_claude_sonnet_4_5/

# Run create tests
poetry run robot --outputdir robot_results --include create robot_tests_claude_sonnet_4_5/

# Run UI tests only
poetry run robot --outputdir robot_results --include ui robot_tests_claude_sonnet_4_5/

# Run API tests only
poetry run robot --outputdir robot_results --include api robot_tests_claude_sonnet_4_5/
```

### Run Specific Test

```bash
poetry run robot --outputdir robot_results -t "User Can Add A New Book" robot_tests_claude_sonnet_4_5/
```

## Test Design Principles

### Gherkin Syntax
All test cases follow the Given-When-Then structure:
- **Given**: Setup and preconditions
- **When**: Actions performed
- **Then**: Expected outcomes

### Keyword Organization
- **Test cases**: Use Gherkin syntax (Given/When/Then)
- **Keywords**: Use imperative style without Gherkin prefixes
- **Resource files**: Contain reusable keywords organized by domain

### Tags
- `ui`: UI tests
- `api`: API tests
- `smoke`: Critical smoke tests
- `create`: Create operations
- `read`: Read operations
- `update`: Update operations
- `delete`: Delete operations
- `favorite`: Favorite functionality
- `search`: Search functionality
- `filter`: Filter functionality
- `negative`: Negative test cases
- `validation`: Validation test cases

## Configuration

Variables can be customized in `resources/common.resource`:
- `BASE_URL`: Application base URL (default: http://localhost:8000)
- `BROWSER`: Browser to use (default: chromium)
- `HEADLESS`: Run browser in headless mode (default: True)
- `TIMEOUT`: Default timeout for operations (default: 10s)

## Best Practices

1. **Wait Conditions**: Use proper wait conditions instead of fixed sleeps
2. **Isolation**: Each test should be independent
3. **Cleanup**: Suite teardown ensures proper cleanup
4. **Descriptive Names**: Test names clearly describe what is being tested
5. **Documentation**: Each test has documentation explaining its purpose
6. **Tags**: Tests are properly tagged for selective execution
