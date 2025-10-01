# Books Library Robot Framework Test Suite

This comprehensive test suite provides automated acceptance testing for the Books Library application using Robot Framework with Browser Library and Gherkin syntax.

## 📁 Test Structure

```
robot_tests/
├── books_api.robot              # API acceptance tests
├── books_ui.robot               # UI acceptance tests  
├── resources/
│   └── common.resource          # Common variables and settings
├── keywords/
│   ├── api_keywords.resource    # API-specific keywords
│   └── ui_keywords.resource     # UI-specific keywords
├── robot.conf                   # Robot Framework configuration
├── run_tests.sh                 # Test execution script
└── README.md                    # This documentation
```

## 🎯 Test Coverage

### API Tests (18 scenarios)
- ✅ **CRUD Operations**: Create, Read, Update, Delete books
- ✅ **Data Validation**: Required fields, data types, constraints
- ✅ **Error Handling**: 404, 422 responses, edge cases
- ✅ **Favorite Management**: Toggle favorite status
- ✅ **Multiple Books**: Bulk operations, concurrent access
- ✅ **Data Consistency**: Multi-operation integrity

### UI Tests (18 scenarios)
- ✅ **Homepage Verification**: Layout, elements, navigation
- ✅ **Book Management**: Add, edit, delete books via UI
- ✅ **Search Functionality**: Search by title and author
- ✅ **Filtering**: Category and favorite status filters
- ✅ **Sorting**: Sort by title, author, page count
- ✅ **Form Validation**: Client-side validation testing
- ✅ **User Interactions**: Favorite toggling, modal operations
- ✅ **Responsive Design**: Multi-screen size testing

## 🏷️ Test Tags

### Priority Tags
- `critical` - Essential functionality tests
- `smoke` - Basic functionality verification

### Feature Tags
- `api` - API-related tests
- `ui` - User interface tests
- `crud` - Create, Read, Update, Delete operations
- `search` - Search functionality
- `filter` - Filtering functionality
- `sort` - Sorting functionality
- `validation` - Data validation tests
- `error-handling` - Error scenario tests

## 🚀 Quick Start

### Prerequisites
```bash
# Install dependencies
poetry install

# Install Browser Library
poetry run rfbrowser init

# Start the application
docker-compose up -d
```

### Running Tests

#### Using the Test Script (Recommended)
```bash
# Run all tests
./robot_tests/run_tests.sh

# Run specific test types
./robot_tests/run_tests.sh smoke
./robot_tests/run_tests.sh critical
./robot_tests/run_tests.sh api
./robot_tests/run_tests.sh ui
./robot_tests/run_tests.sh quick

# Get help
./robot_tests/run_tests.sh help
```

#### Using Robot Framework Directly
```bash
# Run all tests
poetry run robot --outputdir robot_results robot_tests/

# Run with specific tags
poetry run robot --outputdir robot_results --include smoke robot_tests/
poetry run robot --outputdir robot_results --include critical robot_tests/
poetry run robot --outputdir robot_results --include api robot_tests/
poetry run robot --outputdir robot_results --include ui robot_tests/

# Run specific test files
poetry run robot --outputdir robot_results robot_tests/books_api.robot
poetry run robot --outputdir robot_results robot_tests/books_ui.robot

# Run with custom configuration
poetry run robot --argumentfile robot_tests/robot.conf robot_tests/
```

## ⚙️ Configuration

### Environment Variables
- `BASE_URL` - Application base URL (default: http://localhost:8000)
- `BROWSER` - Browser for UI tests (default: chromium)
- `HEADLESS` - Headless browser mode (default: true)

### Example Configurations
```bash
# Test against different environment
BASE_URL=http://staging.example.com ./robot_tests/run_tests.sh

# Run with visible browser
HEADLESS=false ./robot_tests/run_tests.sh ui

# Custom browser
BROWSER=firefox ./robot_tests/run_tests.sh ui
```

## 📊 Test Scenarios

### API Test Scenarios (Gherkin Format)

#### CRUD Operations
- **Scenario**: API can retrieve all books when database is empty
- **Scenario**: API can create a new book with valid data
- **Scenario**: API can retrieve a specific book by ID
- **Scenario**: API can update an existing book
- **Scenario**: API can delete an existing book

#### Error Handling
- **Scenario**: API returns 404 when requesting non-existent book
- **Scenario**: API returns 404 when updating non-existent book
- **Scenario**: API returns 404 when deleting non-existent book
- **Scenario**: API returns 404 when toggling favorite for non-existent book

#### Data Validation
- **Scenario**: API validates required fields when creating a book
- **Scenario**: API validates data types when creating a book
- **Scenario**: API validates required fields when updating a book

#### Advanced Operations
- **Scenario**: API can toggle book favorite status to true/false
- **Scenario**: API can handle multiple books operations
- **Scenario**: API handles concurrent book operations correctly
- **Scenario**: API maintains data consistency across operations

### UI Test Scenarios (Gherkin Format)

#### Basic Functionality
- **Scenario**: User can view the Books Library homepage
- **Scenario**: User can add a new book successfully
- **Scenario**: User can add books with different categories

#### Search and Filter
- **Scenario**: User can search for books by title
- **Scenario**: User can search for books by author
- **Scenario**: User can filter books by category
- **Scenario**: User can filter books by favorite status
- **Scenario**: User can combine search and filter operations

#### Sorting
- **Scenario**: User can sort books by title
- **Scenario**: User can sort books by author
- **Scenario**: User can sort books by page count

#### Book Management
- **Scenario**: User can mark a book as favorite
- **Scenario**: User can unmark a book as favorite
- **Scenario**: User can edit a book's information
- **Scenario**: User can delete a book

#### User Experience
- **Scenario**: User sees appropriate feedback when no books match filters
- **Scenario**: Form validation prevents submission of invalid data
- **Scenario**: User interface is responsive and accessible

## 🔧 CI/CD Integration

### GitLab CI/CD Pipeline Integration
The test suite is designed to integrate with the existing GitLab CI/CD pipeline:

```yaml
# Quick tests (smoke + critical)
robot-smoke-tests:
  stage: test:quick
  script:
    - ./robot_tests/run_tests.sh smoke

# Comprehensive tests
robot-comprehensive-tests:
  stage: test:comprehensive
  script:
    - ./robot_tests/run_tests.sh all
```

### Docker Integration
Tests can run in containerized environments using the provided Docker configuration:

```bash
# Using the robot test image from CI/CD
docker run --rm \
  --network books-network \
  -v $(pwd)/robot_results:/workspace/robot_results \
  -e BASE_URL="http://books-service:8000" \
  robot-tests:latest \
  robot --outputdir robot_results robot_tests/
```

## 📈 Test Reports

After test execution, reports are generated in the `robot_results/` directory:

- `report.html` - Comprehensive test report with statistics
- `log.html` - Detailed test execution log
- `output.xml` - Machine-readable test results (for CI/CD)

### Report Features
- **Test Statistics**: Pass/fail counts, execution times
- **Tag-based Filtering**: Filter results by test tags
- **Detailed Logs**: Step-by-step execution details
- **Screenshots**: Automatic screenshots on UI test failures
- **Keyword Documentation**: Embedded keyword documentation

## 🧪 Test Data Management

### Automatic Cleanup
- Tests automatically clean up data between executions
- Each test starts with a clean database state
- Failed tests don't affect subsequent test runs

### Random Test Data
- Uses random data generation for realistic testing
- Avoids test data conflicts
- Ensures tests work with various data combinations

### Test Isolation
- Each test scenario is independent
- No dependencies between test cases
- Parallel execution safe

## 🔍 Debugging and Troubleshooting

### Common Issues

#### Service Not Running
```bash
# Check if service is running
curl -f http://localhost:8000/books/

# Start service
docker-compose up -d

# Check service logs
docker-compose logs books-service
```

#### Browser Issues
```bash
# Reinstall browser binaries
poetry run rfbrowser init

# Run with visible browser for debugging
HEADLESS=false ./robot_tests/run_tests.sh ui
```

#### Test Failures
```bash
# Run specific failing test
poetry run robot --outputdir robot_results --test "*specific test name*" robot_tests/

# Run with debug logging
poetry run robot --outputdir robot_results --loglevel DEBUG robot_tests/

# Run without exit on failure
poetry run robot --outputdir robot_results --exitonfailure robot_tests/
```

### Debug Mode
```bash
# Run with visible browser and debug logging
HEADLESS=false poetry run robot \
  --outputdir robot_results \
  --loglevel DEBUG \
  --variable TIMEOUT:30s \
  robot_tests/books_ui.robot
```

## 📚 Keywords Documentation

### Common Keywords (`resources/common.resource`)
- Environment setup and teardown
- Test data generation and cleanup
- Configuration variables

### API Keywords (`keywords/api_keywords.resource`)
- REST API operations (CRUD)
- Error handling and validation
- Data verification and consistency checks

### UI Keywords (`keywords/ui_keywords.resource`)
- Browser automation and page interactions
- Form operations and validations
- Search, filter, and sort operations
- Modal and dialog handling

## 🎯 Best Practices

### Test Design
- **Gherkin Syntax**: All tests use Given-When-Then structure
- **Descriptive Names**: Clear, business-readable test names
- **Proper Tagging**: Consistent tag usage for test organization
- **Independent Tests**: No dependencies between test cases

### Maintainability
- **Keyword Separation**: Logical separation of UI and API keywords
- **Reusable Components**: Common operations as reusable keywords
- **Configuration Management**: Centralized configuration
- **Documentation**: Comprehensive inline documentation

### Performance
- **Parallel Execution**: Tests designed for parallel execution
- **Efficient Selectors**: Optimized CSS selectors
- **Smart Waits**: Appropriate wait strategies
- **Resource Cleanup**: Automatic cleanup prevents resource leaks

## 🔄 Continuous Integration

### Pipeline Stages
1. **Build**: Build application and test images
2. **Quick Tests**: Smoke and critical tests
3. **Comprehensive Tests**: Full test suite
4. **Security**: Security scanning

### Test Execution Strategy
- **Fail Fast**: Critical tests run first
- **Parallel Execution**: Independent test suites run in parallel
- **Artifact Collection**: Test reports and logs preserved
- **Retry Logic**: Automatic retry for flaky tests

### Quality Gates
- All smoke tests must pass before deployment
- Critical tests must pass for merge requests
- Comprehensive tests run on main branch
- Test coverage reports generated

## 📞 Support

For issues or questions about the test suite:
1. Check the test reports in `robot_results/`
2. Review the logs for detailed error information
3. Use debug mode for interactive troubleshooting
4. Consult the keyword documentation in the reports