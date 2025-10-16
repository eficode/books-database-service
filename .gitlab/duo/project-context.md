# Project Context

## Overview

This project is a books database service with the following components:

- **FastAPI backend service** for book management
- **SQLite database** for data storage
- **React frontend** for user interaction
- **Robot Framework** for UI testing

## Key Domain Concepts

- Books have properties: title, author, pages, category, favorite status
- Users can add, edit, delete, search, and favorite books
- Categories are used for filtering books

## Technical Constraints

- We use Docker for containerization
- CI/CD pipeline runs tests on each commit
- Frontend communicates with backend via REST API
- Backend uses SQLite for simplicity
- Robot Framework is used for end-to-end UI testing

## Robot Framework Guidelines

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