#!/bin/bash
# Run flake8 linting

echo "Running flake8 linting..."
poetry run flake8 fastapi_demo/ tests/ scripts/
echo "Linting completed."
