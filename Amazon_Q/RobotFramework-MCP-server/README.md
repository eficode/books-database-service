Robot Framework MCP Server for Amazon Q

This setup allows Amazon Q to run Robot Framework tests using a persistent Docker container.
🚀 Quick Start

    Build the image:

bash

   chmod +x setup.sh
   ./setup.sh

    Start the persistent container:

bash

   chmod +x start-container.sh
   ./start-container.sh

    Tests are mounted from ../../robot_tests_claude_sonnet_4_5
    Results are written to ../../robot_results

📁 Directory Structure

.
├── Dockerfile               # Robot Framework + MCP server image
├── server.py                # MCP server implementation
├── setup.sh                 # Build script
├── start-container.sh       # Start persistent container
└── amazonq/
    └── agents/
        └── default.json    # Amazon Q agent configuration

🔧 How It Works
Persistent Container

The start-container.sh script:

    Stops any existing container
    Starts a new persistent container named RobotFramework-mcp-persistent
    Mounts tests from ../../robot_tests_claude_sonnet_4_5 (read-only)
    Mounts results to ../../robot_results
    Keeps running in the background

When Amazon Q needs to run tests, it executes:
bash

docker exec -i RobotFramework-mcp-persistent python /app/server.py

The container:

    Stays running for fast test execution
    Runs the requested tests
    Writes results to ../../robot_results/

Available MCP Tools

    run_suite(suite_path, include_tags, exclude_tags, variables) - Run entire test suite
    run_test_by_name(test_name, suite_path, variables) - Run specific test
    list_tests(suite_path) - List all available tests

🧪 Manual Testing

Test the container manually:
bash

# Build image
./setup.sh

# Start persistent container
./start-container.sh

# Check container is running
docker ps | grep RobotFramework-mcp-persistent

📝 Configuration

The amazonq/agents/default.json is configured to use docker exec with the persistent container:
json

"args": [
  "exec",
  "-i",
  "RobotFramework-mcp-persistent",
  "python",
  "/app/server.py"
]

Environment Variables

The container uses these environment variables:

    ROBOT_OUTPUT_DIR=/tmp/results - Where test results are written
    RF_TESTS_DIR=/tests - Where test files are read from
    BROWSER=chromium - Default browser (can be overridden)
    HEADLESS=true - Run browser in headless mode

Network Configuration

The container uses `--network host` to access localhost:8000 where the books service runs.

🔍 Troubleshooting
Container not starting
bash

# Check if image exists
docker images | grep robotframework-mcp

# Rebuild if needed
./setup.sh

# Restart container
./start-container.sh

Permission issues
bash

# Ensure results directory is writable
chmod 777 robot_results/

Test execution logs

Results are written to /tmp/results inside the container and also mounted to ../../robot_results/:

    output.xml - Detailed test execution data
    log.html - Test execution log
    report.html - Test execution report

📚 Tests Location

Robot Framework tests are located in:

    ../../robot_tests_claude_sonnet_4_5/

The container mounts this directory as read-only at /tests

🎯 Container Management

Start container:
bash

./start-container.sh

Stop container:
bash

docker stop RobotFramework-mcp-persistent

Remove container:
bash

docker rm RobotFramework-mcp-persistent

