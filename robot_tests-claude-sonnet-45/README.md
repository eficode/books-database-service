# Books Library Robot Framework Tests

This directory contains comprehensive acceptance tests for the Books Library application using Robot Framework with Browser Library and Gherkin syntax.

## Test Structure

```
robot_tests/
├── books_ui.robot              # UI acceptance tests
├── books_api.robot             # API acceptance tests  
├── integration_tests.robot     # Integration tests (UI + API)
├── resources/
│   └── common.resource         # Shared variables and keywords
├── keywords/
│   ├── ui_keywords.resource    # UI-specific keywords
│   └── api_keywords.resource   # API-specific keywords
├── robot.yaml                  # Robot Framework configuration
└── README.md                   # This file
```

## Test Categories

### UI Tests (`books_ui.robot`)
- **Smoke Tests**: Basic functionality verification
- **CRUD Operations**: Create, Read, Update, Delete books
- **Search & Filter**: Search by title/author, filter by category/favorites
- **Sorting**: Sort by title, author, pages, category
- **Form Validation**: Input validation and error handling
- **Modal Operations**: Edit book modal interactions
- **State Management**: Navigation and filter combinations

### API Tests (`books_api.robot`)
- **Health Checks**: API availability and basic responses
- **CRUD Operations**: Complete REST API testing
- **Error Handling**: 404 errors, validation errors
- **Data Validation**: Field validation, data types
- **Performance**: Response times, large data handling
- **Special Characters**: Unicode and special character support

### Integration Tests (`integration_tests.robot`)
- **Data Synchronization**: UI ↔ API data consistency
- **Real-time Updates**: Live data synchronization
- **Error Recovery**: Graceful error handling
- **Concurrent Operations**: Multi-source data integrity
- **Cross-session Persistence**: Data persistence across sessions

## Test Tags

Tests are organized with the following tags:

- `smoke`: Essential functionality tests (run first)
- `crud`: Create, Read, Update, Delete operations
- `ui`: User interface tests
- `api`: REST API tests
- `integration`: Combined UI/API tests
- `search`: Search functionality
- `filter`: Filtering functionality
- `sort`: Sorting functionality
- `validation`: Input validation tests
- `error-handling`: Error scenario tests
- `performance`: Performance and load tests

## Prerequisites

1. **Python 3.8+** with pip
2. **Node.js 16+** (for Browser Library)
3. **Docker & Docker Compose** (for containerized execution)

## Installation

### Local Development Setup

```bash
# Install Robot Framework dependencies
pip install -r requirements-robot.txt

# Initialize Browser Library (downloads browser binaries)
python -m Browser.entry init

# Verify installation
robot --version
```

### Docker Setup (Recommended)

The tests are designed to run in Docker containers for consistency:

```bash
# Build and run tests using provided scripts
./scripts/run_robot_tests.sh

# Or run specific test suites
./scripts/run_robot_tests_local.sh
```

## Running Tests

### Quick Start

```bash
# Run all smoke tests
robot --include smoke robot_tests/

# Run UI tests only
robot robot_tests/books_ui.robot

# Run API tests only  
robot robot_tests/books_api.robot

# Run integration tests
robot robot_tests/integration_tests.robot
```

### Advanced Execution

```bash
# Run with specific browser
robot --variable BROWSER:firefox robot_tests/

# Run in headed mode (see browser)
robot --variable HEADLESS:false robot_tests/

# Run with custom base URL
robot --variable BASE_URL:http://localhost:3000 robot_tests/

# Run specific test by name
robot --test "User Can Add A New Book Successfully" robot_tests/

# Run tests with specific tags
robot --include "smoke OR crud" robot_tests/

# Exclude slow tests
robot --exclude performance robot_tests/

# Parallel execution
pabot --processes 4 robot_tests/
```

### CI/CD Execution

```bash
# Smoke tests (fast feedback)
robot --include smoke --outputdir robot_results/smoke robot_tests/

# Full test suite
robot --outputdir robot_results --variable HEADLESS:true robot_tests/

# Generate combined report
rebot --outputdir robot_results robot_results/smoke/output.xml robot_results/output.xml
```

## Configuration

### Environment Variables

- `BASE_URL`: Application base URL (default: http://localhost:8000)
- `BROWSER`: Browser to use (chromium, firefox, webkit)
- `HEADLESS`: Run in headless mode (true/false)
- `VIEWPORT_WIDTH`: Browser viewport width (default: 1920)
- `VIEWPORT_HEIGHT`: Browser viewport height (default: 1080)

### Robot Framework Configuration

The `robot.yaml` file contains default settings:

```yaml
--outputdir: robot_results
--loglevel: INFO
--include: smoke
--variable: BROWSER:chromium
--variable: HEADLESS:true
```

## Test Data Management

### Dynamic Test Data

Tests use dynamic test data generation:

```robot
${book_data}=    Generate Random Book Data    TestPrefix
```

### Test Isolation

Each test case:
- Starts with a clean database
- Creates its own test data
- Cleans up after execution

### API Integration

Tests can create data via API for performance:

```robot
Given I Have Multiple Books In The Database    20
```

## Debugging Tests

### Screenshots on Failure

Screenshots are automatically captured on test failures:

```robot
Run Keyword If Test Failed    Take Screenshot On Failure
```

### Browser Console Logs

Console logs are captured for debugging:

```robot
Run Keyword If Test Failed    Log Browser Console
```

### Interactive Debugging

```bash
# Run with debug library
robot --listener DebugLibrary robot_tests/

# Pause execution at specific points
Debug    # Add this keyword in test
```

### Verbose Logging

```bash
# Detailed logging
robot --loglevel DEBUG robot_tests/

# Trace level (very detailed)
robot --loglevel TRACE robot_tests/
```

## Reporting

### Standard Reports

Robot Framework generates three main reports:

- `report.html`: High-level test results
- `log.html`: Detailed execution log
- `output.xml`: Machine-readable results

### Enhanced Reporting

```bash
# Custom report titles
robot --reporttitle "Books Library Test Results" robot_tests/

# Timestamped outputs
robot --timestampoutputs robot_tests/

# Custom metadata
robot --metadata "Version:1.0" --metadata "Environment:Test" robot_tests/
```

### Combining Results

```bash
# Combine multiple test runs
rebot --outputdir combined_results output1.xml output2.xml output3.xml
```

## Best Practices

### Test Organization

1. **Use Gherkin syntax** for readable test scenarios
2. **Group related tests** in the same file
3. **Use descriptive test names** that explain the scenario
4. **Tag tests appropriately** for selective execution

### Keyword Design

1. **Follow Given-When-Then pattern** for clarity
2. **Create reusable keywords** in resource files
3. **Use appropriate abstraction levels** (high-level for tests, low-level for implementation)
4. **Include proper documentation** for all keywords

### Data Management

1. **Use dynamic test data** to avoid conflicts
2. **Clean up after tests** to ensure isolation
3. **Verify test preconditions** before execution
4. **Handle test data dependencies** explicitly

### Error Handling

1. **Expect and handle failures** gracefully
2. **Provide meaningful error messages** in assertions
3. **Use appropriate timeouts** for different operations
4. **Capture debugging information** on failures

## Troubleshooting

### Common Issues

1. **Browser not found**: Run `python -m Browser.entry init`
2. **Connection refused**: Ensure application is running
3. **Element not found**: Check selectors and wait conditions
4. **Timeout errors**: Increase timeout values or check application performance

### Performance Issues

1. **Slow test execution**: Use headless mode and optimize waits
2. **Memory issues**: Limit parallel execution or increase resources
3. **Network timeouts**: Check application responsiveness

### CI/CD Issues

1. **Docker networking**: Ensure proper container networking
2. **Resource constraints**: Adjust container resources
3. **Timing issues**: Add appropriate waits for CI environments

## Contributing

### Adding New Tests

1. Follow the existing Gherkin pattern
2. Add appropriate tags for categorization
3. Include both positive and negative test cases
4. Update documentation as needed

### Modifying Keywords

1. Maintain backward compatibility
2. Update all affected tests
3. Add proper documentation
4. Consider impact on existing tests

### Test Maintenance

1. Regular review of test results
2. Update selectors when UI changes
3. Refactor duplicate code into keywords
4. Keep test data and expectations current

## Integration with CI/CD

The tests are integrated with GitLab CI/CD pipeline:

- **Smoke tests** run in parallel with API tests for fast feedback
- **Full UI tests** run after smoke tests pass
- **Results are archived** and available in pipeline artifacts
- **Failed tests trigger notifications** and can be re-run

See `.gitlab-ci.yml` for complete CI/CD configuration.