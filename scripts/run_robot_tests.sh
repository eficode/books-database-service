#!/bin/bash
# Run Robot Framework UI tests

# Setup
echo "Setting up Robot Framework tests..."
poetry run python -m Browser.entry init

# Run all robot tests
echo "Running Robot Framework tests..."
poetry run robot --outputdir robot_results robot_tests/

echo "Done!"