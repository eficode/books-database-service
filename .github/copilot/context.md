# Project Context and Domain Knowledge

## Project Overview

This is a books database service designed to help users manage their personal book collections. The application provides a complete solution for cataloging, searching, and organizing books with a modern web interface.

## Domain Model

### Core Entities

#### Book
The central entity representing a book in the system with the following properties:
- **Title**: The name of the book (required)
- **Author**: The book's author (required)
- **Pages**: Number of pages (optional, integer)
- **Category**: Classification for filtering (e.g., Fiction, Non-Fiction, Science, etc.)
- **Favorite**: Boolean flag indicating user preference
- **ID**: Unique identifier for database operations

#### Category
Used for organizing and filtering books:
- Predefined categories: Fiction, Non-Fiction, Science, Biography, etc.
- Users can filter books by category
- Categories help with organization and discovery

### Business Rules

- Books must have at least a title and author
- Categories are used for filtering and organization
- Favorite status is user-specific preference
- Search functionality covers title and author fields
- Sorting is available by title, author, and pages

## User Workflows

### Primary User Stories

1. **Add New Book**: Users can add books with title, author, pages, and category
2. **Browse Collection**: Users can view all books in a paginated list
3. **Search Books**: Users can search by title or author
4. **Filter by Category**: Users can filter books by category
5. **Mark Favorites**: Users can mark/unmark books as favorites
6. **Edit Book Details**: Users can update book information
7. **Delete Books**: Users can remove books from their collection

### Critical User Flows (Covered by E2E Tests)
- Complete book lifecycle: Add → View → Edit → Delete
- Search and filtering functionality
- Favorite management
- Category-based organization

## Technical Context

### Technology Stack
- **Backend**: FastAPI (Python) - High-performance async web framework
- **Database**: SQLite - Lightweight, file-based database for simplicity
- **Frontend**: React - Component-based user interface
- **Testing**: Robot Framework - Browser automation for E2E testing
- **Containerization**: Docker - Consistent deployment environment

### Deployment Architecture
- **Development**: Local SQLite database
- **CI/CD**: Automated testing pipeline on each commit
- **Staging**: Container deployment with test data
- **Production**: Containerized deployment with persistent storage

### Integration Points
- **API Layer**: RESTful endpoints for frontend communication
- **Database Layer**: SQLAlchemy ORM for data operations
- **Static Files**: Served directly by FastAPI for simplicity
- **Testing Layer**: Robot Framework for user acceptance testing

## Development Constraints

### Technical Limitations
- SQLite for simplicity (not suitable for high concurrency)
- Single-user application (no authentication/authorization)
- File-based storage (database file must be persistent)

### Quality Requirements
- All new features must include unit tests
- Critical workflows require Robot Framework tests
- API changes must update OpenAPI documentation
- Docker containerization for consistent environments