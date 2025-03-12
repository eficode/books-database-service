#!/bin/bash
# Run linting and type checking

echo "Running flake8 linting..."
poetry run flake8 fastapi_demo/ tests/ scripts/

echo "Running Black for code formatting..."
poetry run black --check fastapi_demo/ tests/ scripts/

echo "Running MyPy for type checking..."
poetry run mypy fastapi_demo/ tests/ scripts/

echo "Linting and type checking completed."
