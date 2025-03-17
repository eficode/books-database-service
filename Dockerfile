FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY pyproject.toml poetry.lock* README.md /app/
RUN pip install --no-cache-dir poetry && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root

# Copy application
COPY . /app/

# Create empty database directory
RUN mkdir -p /app/data

# Expose port
EXPOSE 8000

# Install wget for healthcheck
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Run the application
CMD ["uvicorn", "fastapi_demo.main:app", "--host", "0.0.0.0", "--port", "8000"]
