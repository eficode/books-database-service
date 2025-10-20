#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Setting up Robot Framework MCP Server..."
echo "   Location: RobotFramework-MCP-server folder"
echo ""

# Build the Docker image
echo "🐳 Building Docker image..."
docker build -t robotframework-mcp:latest .

echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Start the persistent container:"
echo "      ./start-container.sh"
echo ""
echo "   2. The container will mount tests from: ../../robot_tests_claude_sonnet_4_5"
echo "   3. Test results will be in: ../../robot_results"
echo ""
echo "   Note: This uses a persistent container approach for better performance"