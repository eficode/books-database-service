#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="RobotFramework-mcp-persistent"
IMAGE_NAME="robotframework-mcp:latest"
# Go up one level from Amazon_Q/RobotFramework-MCP-server to books-database-service
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TESTS_DIR="${PROJECT_ROOT}/robot_tests_claude_sonnet_4_5"
RESULTS_DIR="${PROJECT_ROOT}/robot_results"

echo "🚀 Starting persistent MCP Robot Framework container..."

# Stop and remove the persistent container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$" || true; then
    echo "🛑 Stopping and removing existing persistent container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
fi

# Clean up any containers using the robotframework-mcp:latest image
echo "🧹 Cleaning up any containers using robotframework-mcp:latest image..."
docker ps -a --filter "ancestor=${IMAGE_NAME}" --format '{{.Names}}' | while read -r name; do
    if [ -n "$name" ]; then
        echo "   Removing: $name"
        docker stop "$name" 2>/dev/null || true
        docker rm -f "$name" 2>/dev/null || true
    fi
done || true

# Clean up any containers with RobotFramework-mcp in the name
echo "🧹 Cleaning up any containers with 'RobotFramework-mcp' in name..."
docker ps -a --format '{{.Names}}' | grep "RobotFramework-mcp" | while read -r name; do
    if [ -n "$name" ]; then
        echo "   Removing: $name"
        docker stop "$name" 2>/dev/null || true
        docker rm -f "$name" 2>/dev/null || true
    fi
done || true

echo ""
echo "📦 Starting new persistent container..."
echo "   Tests from: $TESTS_DIR"
echo "   Results to: $RESULTS_DIR"
echo ""

# Start container in background with tail to keep it running
docker run -d \
    --name "$CONTAINER_NAME" \
    --network host \
    --entrypoint tail \
    -v "${TESTS_DIR}:/tests:ro" \
    -v "${RESULTS_DIR}:/results:rw" \
    "$IMAGE_NAME" \
    -f /dev/null

echo ""
echo "✅ Persistent container started: $CONTAINER_NAME"
echo ""
echo "🔍 Verifying container is running..."
docker ps --filter "name=$CONTAINER_NAME"
echo ""
echo "📝 Update your test.json to use:"
echo '   "command": "/usr/local/bin/docker"'
echo '   "args": ['
echo '     "exec",'
echo '     "-i",'
echo '     "RobotFramework-mcp-persistent",'
echo '     "python",'
echo '     "/app/server.py"'
echo '   ]'
echo ""
echo "🛑 To stop: docker stop $CONTAINER_NAME"
echo "🗑️  To remove: docker rm $CONTAINER_NAME"