FROM mcr.microsoft.com/playwright/python:v1.48.0-jammy

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Europe/Helsinki

WORKDIR /app

# Node.js is required by robotframework-browser (Playwright via Node)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Robot Framework + Browser + Requests + MCP SDK
RUN pip install --no-cache-dir \
    robotframework \
    robotframework-browser \
    robotframework-requests \
    "mcp[cli]" \
    && rfbrowser init

COPY server.py /app/server.py

# Safer browser execution
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app

ENV ROBOT_OUTPUT_DIR=/tmp/results
ENV RF_TESTS_DIR=/tests

# Switch to appuser AFTER all root operations are done
USER appuser

ENTRYPOINT ["python", "-u", "/app/server.py"]