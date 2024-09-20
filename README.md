## Running the Application with Poetry

1. **Install Poetry**: If you haven't installed Poetry yet, you can do so by running the following command in your terminal:

    ```bash
    curl -sSL https://install.python-poetry.org | python3 -
    ```

2. **Clone the Repository**: Clone the repository to your local machine by running the following command in your terminal:

    ```bash
    git clone <your-repository-url>
    ```

3. **Install the Dependencies**: Change to the directory where the repository was cloned and run the following command to install the dependencies:

    ```bash
    poetry install
    ```

4. **Run the Application**: Run your FastAPI application with the following command:

    ```bash
    poetry run dev-server
    ```

Your application should now be running at http://localhost:8000/docs.

### Tips

**Activate the Virtual Environment**: Run the following command to activate the virtual environment:

    poetry shell

## Run tests

To run the tests, run the following command:

    poetry run pytest
