# Robot Framework Test Suite Documentation

## Overview
This documentation describes the Robot Framework test automation structure created for the Books Database Service application.

## Directory Structure
```
robot_tests/
├── books_ui.robot          # UI acceptance tests with Browser Library
├── books_api.robot         # API acceptance tests with RequestsLibrary
└── resources/
    ├── common.resource      # Common keywords and variables
    ├── ui_keywords.resource # UI-specific keywords for browser automation
    └── api_keywords.resource # API-specific keywords for REST testing
```

## Test Files

### 1. books_ui.robot
**Purpose:** UI acceptance tests for the Books Library web interface

**Features tested:**
- Opening and viewing the Books Library UI
- Adding new books through the web form
- Adding multiple books consecutively
- Searching for books by title and author
- Filtering books by category
- Marking/unmarking books as favorites
- Filtering favorite books
- Sorting books by different fields (title, author, pages, category)
- Toggling sort direction
- Editing book information
- Deleting books
- Viewing book counts
- Handling empty search results

**Test count:** 20+ scenarios

**Tags:** ui, acceptance, books, crud, search, filter, favorite, sort, display

### 2. books_api.robot
**Purpose:** API acceptance tests for the Books REST API

**Features tested:**
- Creating new books via API
- Retrieving all books
- Retrieving specific books by ID
- Updating existing books
- Deleting books
- Toggling favorite status
- Error handling (404 for non-existent books)
- Default values (category, favorite status)
- Multiple categories support
- Concurrent operations
- Field validation
- Data integrity
- Performance (response time)

**Test count:** 25+ scenarios

**Tags:** api, acceptance, books, crud, create, read, update, delete, favorite, validation, performance

## Resource Files

### common.resource
**Purpose:** Shared keywords, variables, and settings for all tests

**Key Features:**
- Application URL configuration
- Browser settings (browser type, headless mode, timeout)
- Docker environment management (start/stop containers)
- Test data management (create/clean test books)
- Random data generation
- Common verification keywords

**Variables:**
- `${BASE_URL}` - Application base URL (http://localhost:8000)
- `${BROWSER}` - Browser type (chromium)
- `${HEADLESS}` - Headless mode setting
- Test book data constants

**Keywords:**
- `Start Docker Environment` - Starts application via docker-compose
- `Stop Docker Environment` - Stops and removes containers
- `Clean Up Test Data` - Removes all test data
- `Create Test Book` - Creates a book via API
- `Generate Random Book Data` - Generates random test data

### ui_keywords.resource
**Purpose:** Browser Library keywords for UI interactions

**Key Features:**
- Page element locators (forms, buttons, search, filters, etc.)
- Browser management (open/close)
- Form interactions (fill, submit, clear)
- Search and filter operations
- Book card interactions (favorite, edit, delete)
- Modal dialog handling
- Verification keywords for UI elements

**Main Keywords:**
- `Open Books UI` - Opens the application in browser
- `Close Books UI` - Closes the browser
- `User Adds New Book` - Adds a book through the form
- `User Searches For Book` - Performs search
- `User Filters By Category` - Applies category filter
- `Book Should Be Visible In List` - Verifies book presence
- `User Clicks Edit Button For Book` - Opens edit modal
- `User Edits Book In Modal` - Updates book information

### api_keywords.resource
**Purpose:** RequestsLibrary keywords for API testing

**Key Features:**
- REST API operations (GET, POST, PUT, DELETE, PATCH)
- Response validation
- Status code verification
- JSON data extraction
- Error message verification
- List operations
- Batch operations (create/delete multiple books)

**Main Keywords:**
- `API Get All Books` - Retrieves all books
- `API Get Book By ID` - Retrieves specific book
- `API Create Book` - Creates a new book
- `API Update Book` - Updates existing book
- `API Delete Book` - Deletes a book
- `API Toggle Book Favorite` - Changes favorite status
- `API Response Should Be Successful` - Verifies success status
- `Book Should Exist In Database` - Verifies book existence

## Running the Tests

### Prerequisites
1. Install dependencies:
   ```bash
   poetry install
   ```

2. Initialize Browser Library:
   ```bash
   poetry run python -m Browser.entry init
   ```

### Run All Tests
```bash
# Run all tests in robot_tests folder
poetry run robot --outputdir robot_results robot_tests/

# Run with script
./scripts/run_robot_tests.sh
```

### Run Specific Test Suite
```bash
# Run only UI tests
poetry run robot --outputdir robot_results robot_tests/books_ui.robot

# Run only API tests
poetry run robot --outputdir robot_results robot_tests/books_api.robot
```

### Run Specific Test
```bash
# Run specific test by name
poetry run robot --outputdir robot_results -t "User Can Open Books Library UI" robot_tests/

# Run tests with specific tag
poetry run robot --outputdir robot_results -i smoke robot_tests/
poetry run robot --outputdir robot_results -i api robot_tests/
```

### Run with Different Options
```bash
# Run in headless mode
poetry run robot --outputdir robot_results --variable HEADLESS:True robot_tests/books_ui.robot

# Run with verbose output
poetry run robot --outputdir robot_results --loglevel DEBUG robot_tests/

# Run tests in parallel (with pabot)
poetry run pabot --processes 4 --outputdir robot_results robot_tests/
```

## Test Tags

### By Type
- `ui` - User interface tests
- `api` - API tests
- `acceptance` - Acceptance tests

### By Operation
- `crud` - Create, Read, Update, Delete operations
- `create` - Creation tests
- `read` - Retrieval tests
- `update` - Update tests
- `delete` - Deletion tests

### By Feature
- `search` - Search functionality
- `filter` - Filtering functionality
- `favorite` - Favorite feature
- `sort` - Sorting functionality
- `validation` - Input validation tests
- `performance` - Performance tests

### By Priority
- `smoke` - Smoke tests (critical functionality)
- `critical` - Critical tests
- `negative` - Negative test cases

## Gherkin Syntax

All tests use Gherkin-style BDD syntax with Given-When-Then structure:

```robot
Scenario: User Can Add A New Book Through UI
    Given the application is running
    And user opens the Books UI
    When user adds a new book with title "1984" author "George Orwell" pages "328" category "Fiction"
    Then the book "1984" should be visible in the books list
    And the book should display author "George Orwell"
```

## Test Setup and Teardown

### Suite Level
- **Suite Setup:** 
  - Start Docker containers
  - Wait for application to be ready
  - Clean test data

- **Suite Teardown:**
  - Close browser (if open)
  - Stop Docker containers

### Test Level
- **Test Setup (UI):**
  - Clean test data
  - Open browser

- **Test Teardown (UI):**
  - Close browser

- **Test Setup (API):**
  - Clean test data

## Docker Integration

Tests automatically manage Docker containers:
1. Suite setup starts containers with `docker-compose up -d`
2. Waits for application to be ready
3. Suite teardown stops containers with `docker-compose down`

## Best Practices

1. **Test Isolation:** Each test starts with clean data
2. **Explicit Waits:** Uses Browser Library's smart waiting mechanisms
3. **Readable Test Names:** Descriptive scenario names in Gherkin style
4. **Reusable Keywords:** Common operations extracted to keyword files
5. **Tag Organization:** Multiple tags for flexible test execution
6. **Error Handling:** Proper error verification and negative testing
7. **Data Generation:** Random data generation for concurrent tests

## Troubleshooting

### Browser not found
```bash
poetry run python -m Browser.entry init
```

### Docker connection issues
- Ensure Docker Desktop is running
- Check if port 8000 is available

### Tests failing due to timing
- Increase `${BROWSER_TIMEOUT}` in common.resource
- Add explicit waits in ui_keywords.resource

### API tests failing
- Verify application is running: `curl http://localhost:8000/books`
- Check Docker logs: `docker-compose logs`

## Future Enhancements

1. **Visual Testing:** Add screenshot comparisons
2. **Accessibility Testing:** Add ARIA and WCAG checks
3. **Performance Testing:** Add load testing scenarios
4. **Mobile Testing:** Add mobile viewport tests
5. **Cross-browser Testing:** Run tests on multiple browsers
6. **Data-driven Testing:** Add test data from external files
7. **Report Enhancement:** Custom HTML reports with screenshots
