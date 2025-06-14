#!/bin/bash
# Run Robot Framework UI tests

# Setup
echo "Setting up Robot Framework tests..."
poetry run python -m Browser.entry init

# Run all robot tests (excluding disabled ones)
echo "Running Robot Framework tests..."
poetry run robot --outputdir robot_results --exclude disabled robot_tests/

echo "Done!"