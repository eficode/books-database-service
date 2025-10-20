# Product Overview

## Project Purpose
Books Database Service is a modern web application that provides a complete solution for managing a books library through both a RESTful API and an interactive web interface. The application demonstrates best practices in full-stack development with FastAPI, SQLAlchemy, and vanilla JavaScript.

## Key Features

### API Capabilities
- **CRUD Operations**: Create, read, update, and delete books with full validation
- **Advanced Filtering**: Filter books by title, author, category, and publication year
- **Sorting**: Sort books by any field in ascending or descending order
- **Pagination**: Handle large datasets efficiently with configurable page size
- **OpenAPI Documentation**: Auto-generated interactive API documentation at `/docs`

### User Interface
- **Responsive Design**: Beautiful, mobile-friendly interface built with vanilla JavaScript
- **Real-time Filtering**: Instant search and filter results without page reloads
- **Dynamic Sorting**: Click column headers to sort books
- **Category Management**: Visual categorization of books (Fiction, Non-Fiction, Science, History, etc.)
- **Pagination Controls**: Navigate through large book collections easily

### Data Management
- **SQLite Database**: Lightweight, file-based database for easy deployment
- **Sample Data Generation**: Scripts to populate the database with realistic book data
- **Database Migrations**: Tools for initializing and managing database schema

## Target Users

### Developers
- Learning FastAPI and modern Python web development
- Building RESTful APIs with proper structure and documentation
- Implementing full-stack applications with separation of concerns
- Understanding testing strategies (unit tests with pytest, UI tests with Robot Framework)

### Students
- Studying web application architecture
- Learning API design patterns
- Understanding database integration with ORMs
- Practicing test-driven development

### Teams
- Need a reference implementation for FastAPI projects
- Want to understand Docker containerization for Python applications
- Looking for examples of CI/CD integration with GitHub Actions
- Seeking patterns for Robot Framework UI testing

## Use Cases

1. **API Development Reference**: Demonstrates proper FastAPI project structure with routers, DTOs, and database models
2. **Testing Examples**: Shows both pytest for API testing and Robot Framework for UI testing
3. **Docker Deployment**: Provides Docker and Docker Compose configurations for containerized deployment
4. **CI/CD Pipeline**: Includes GitHub Actions workflow for automated testing
5. **MCP Integration**: Demonstrates Amazon Q integration with Robot Framework through Model Context Protocol servers
