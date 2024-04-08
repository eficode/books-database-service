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

4. **Activate the Virtual Environment**: Run the following command to activate the virtual environment:

    ```bash
    poetry shell
    ```

5. **Run the Application**: Run your FastAPI application with the following command:

    ```bash
    uvicorn fastapi_demo.main:app --reload
    ```

Your application should now be running at http://localhost:8000.

## Run tests

To run the tests, run the following command:

```bash
poetry run pytest
```