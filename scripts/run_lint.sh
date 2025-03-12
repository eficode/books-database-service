#!/bin/bash
# Run linting and type checking

echo "Running flake8 linting on changed files..."
CHANGED_FILES=$(git diff --name-only --diff-filter=ACM | grep '\.py$')

if [ -n "$CHANGED_FILES" ]; then
    poetry run flake8 $CHANGED_FILES
else
    echo "No Python files changed, skipping linting."
fi

echo "Running Black for code formatting..."
poetry run black --check fastapi_demo/ tests/ scripts/

echo "Running MyPy for type checking..."
poetry run mypy fastapi_demo/ tests/ scripts/

echo "Linting and type checking completed."
