# MR Review Instructions

Instructions for reviewing Python code and Robot Framework tests

## Python Code Review

### General
- Check for PEP 8 compliance (line length, naming conventions, indentation)
- Ensure proper docstrings for modules, classes, and functions
- Verify error handling with appropriate try/except blocks
- Check for proper logging instead of print statements
- Confirm no hardcoded credentials or sensitive information
- Verify imports are organized and unnecessary imports removed

### Performance
- Look for inefficient algorithms or data structures
- Check for unnecessary database queries or API calls
- Verify proper use of list/dict comprehensions where appropriate
- Ensure large data processing uses generators where applicable

### Testing
- Verify unit tests cover new functionality
- Check test coverage for edge cases
- Ensure mocks are used appropriately for external dependencies
- Confirm tests are isolated and don't depend on external state

### Security
- Check for SQL injection vulnerabilities
- Verify input validation for user-provided data
- Ensure proper authentication and authorization checks
- Look for potential information disclosure issues

## Robot Framework Review

### General
- Ensure test cases follow a clear, descriptive naming convention
- Use gherkin-style Given/When/Then structure in test cases
- Do not use gherkin-style structure in keywords
- Verify keywords are properly documented
- Check for proper use of tags for test categorization
- Confirm test setup and teardown procedures are appropriate
- Verify variables are properly defined and used

### Structure
- Check for proper test case organization
- Ensure reusable keywords are in resource files
- Verify test suites are logically organized
- Check for proper use of test templates where applicable

### Reliability
- Look for proper wait conditions instead of fixed sleeps
- Verify error handling in test cases
- Check for proper cleanup in teardown procedures
- Ensure tests are not dependent on specific test data

### Best Practices
- Verify page object pattern is used for UI tests
- Check for proper separation of concerns in keywords
- Ensure test data is properly isolated or generated
- Verify tests are not overly complex or brittle

## CI Checks

- Ensure all CI pipeline stages pass
- Verify code quality tools (pylint, flake8) report no issues
- Check test coverage meets minimum threshold
- Confirm no security vulnerabilities reported by security scanners

## Documentation

- Verify README is updated if necessary
- Check for updated API documentation if applicable
- Ensure changelog is updated with new features or fixes
- Confirm any configuration changes are documented