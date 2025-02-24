# Books Database Service

A modern web application for managing a books database with a beautiful UI and API.

## Features

- RESTful API for managing books
- Beautiful and responsive user interface
- Real-time filtering and sorting of books
- Pagination for large datasets
- Categorization of books

## Running the Application

### Using Docker (Recommended)

The easiest way to run the application is using Docker Compose:

1. Make sure you have Docker and Docker Compose installed
2. Clone this repository
3. Run the following command in the project directory:

```bash
docker-compose up -d
```

The application will be available at http://localhost:8000

To stop the application:

```bash
docker-compose down
```

### Using Poetry

1. **Install Poetry**:

    ```bash
    curl -sSL https://install.python-poetry.org | python3 -
    ```

2. **Install the Dependencies**:

    ```bash
    poetry install
    ```

3. **Run the Application**:

    ```bash
    poetry run dev-server
    ```

The application will be available at http://localhost:8000

### Using Python virtual environment

1. **Create and activate a virtual environment**:

    ```bash
    python -m venv .venv
    source .venv/bin/activate  # On Windows: .venv\Scripts\activate
    ```

2. **Install dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

3. **Run the application**:

    ```bash
    python server.py
    ```

The application will be available at http://localhost:8000

## API Documentation

The API documentation is available at http://localhost:8000/docs when the server is running.

## Running Tests

```bash
python -m pytest
```

## Database Initialization

To generate sample books data:

```bash
python scripts/migrate_db.py
python scripts/generate_books.py
```
