# Glossary and Terminology

## Domain Terminology

### Core Business Terms

**Book**
: The primary entity in the system representing a physical or digital book. Contains metadata including title, author, page count, category, and favorite status.

**Author**
: The person who wrote the book. Required field for all books in the system.

**Title**
: The name of the book. Required field that serves as the primary identifier for users.

**Category**
: A classification system for organizing books (e.g., Fiction, Non-Fiction, Science, Biography). Used for filtering and discovery.

**Favorite**
: A boolean flag indicating whether a user has marked a book as a favorite. Used for quick access to preferred books.

**Pages**
: The number of pages in the book. Optional numeric field used for sorting and display.

### User Interface Terms

**Filter**
: A UI mechanism that allows users to display only books matching specific criteria (e.g., by category or favorite status).

**Sort**
: A UI mechanism that orders books by specific properties such as title (alphabetical), author, or page count.

**Search**
: A text-based query mechanism that finds books matching title or author keywords.

**Collection**
: The complete set of books belonging to a user in the system.

## Technical Terminology

### Application Architecture

**API (Application Programming Interface)**
: The RESTful web service endpoints that provide programmatic access to book data and operations.

**CRUD Operations**
: Create, Read, Update, Delete - the four basic operations that can be performed on book entities.

**Endpoint**
: A specific URL path in the API that handles a particular type of request (e.g., `/api/v1/books`).

**Frontend**
: The React-based user interface that users interact with in their web browser.

**Backend**
: The FastAPI Python service that handles business logic, data validation, and database operations.

**Database**
: The SQLite database that provides persistent storage for book data.

### Development Terms

**Component**
: A reusable piece of UI in React that encapsulates specific functionality and rendering logic.

**Hook**
: React functions that allow components to use state and other React features (e.g., useState, useEffect).

**Props**
: Properties passed from parent to child components in React to share data and functionality.

**State**
: Data that can change over time in a React component, triggering re-renders when updated.

### Testing Terminology

**Unit Test**
: Tests that verify individual functions or components in isolation from their dependencies.

**Integration Test**
: Tests that verify the interaction between different parts of the system (e.g., API and database).

**End-to-End (E2E) Test**
: Tests that verify complete user workflows from the browser interface using Robot Framework.

**Test Coverage**
: A metric indicating the percentage of code lines executed during test runs.

**Mock**
: A test double that replaces a real dependency with a controlled substitute for testing purposes.

### DevOps and Deployment

**CI/CD (Continuous Integration/Continuous Deployment)**
: Automated processes for building, testing, and deploying code changes.

**Container**
: A lightweight, portable execution environment that packages the application with its dependencies.

**Docker**
: The containerization platform used to package and deploy the application consistently across environments.

**Pipeline**
: An automated sequence of steps that code changes go through from development to deployment.

### Version Control

**Branch**
: A parallel version of the code repository used for developing features or fixes independently.

**Commit**
: A saved change to the code repository with a descriptive message about what was changed.

**Pull Request (PR)**
: A request to merge changes from one branch into another, typically reviewed before merging.

**Merge**
: The process of integrating changes from one branch into another branch.

**Main Branch**
: The primary branch containing production-ready code (formerly called "master").

### Quality Assurance

**Code Review**
: The process of examining code changes to ensure quality, correctness, and adherence to standards.

**Linting**
: Automated analysis of code to check for style issues, potential errors, and adherence to coding standards.

**Refactoring**
: The process of restructuring code to improve its design, readability, or performance without changing functionality.

**Technical Debt**
: The cost of choosing quick or easy solutions now that may require more work later.

## Acronyms and Abbreviations

- **API**: Application Programming Interface
- **CI/CD**: Continuous Integration/Continuous Deployment
- **CRUD**: Create, Read, Update, Delete
- **CSS**: Cascading Style Sheets
- **E2E**: End-to-End
- **HTML**: HyperText Markup Language
- **HTTP**: HyperText Transfer Protocol
- **JSON**: JavaScript Object Notation
- **ORM**: Object-Relational Mapping
- **PR**: Pull Request
- **REST**: Representational State Transfer
- **SPA**: Single Page Application
- **SQL**: Structured Query Language
- **UI**: User Interface
- **URL**: Uniform Resource Locator