# Calculator MCP Server

A simple MCP server that provides hello and calculation tools.

## Build and Setup

1. Build the Docker image:
```bash
cd Amazon_Q/calculator-mcp
docker build -t calculator-mcp .
```

2. Start the MCP server:
```bash
docker run -d -i --name calculator-mcp-server calculator-mcp:latest
```

3. Test the server locally:
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | docker run -i calculator-mcp
```

## Enable in Amazon Q

1. Open Amazon Q settings: **Amazon Q → Tools → Add new MCP server**
2. Choose scope:
   - **Global** - Used globally across all workspaces
   - **This workspace** - Only used in this workspace
3. Configure the server:
   - **Name**: `Calculator`
   - **Transport**: `stdio`
   - **Command**: `/usr/local/bin/docker`
   - **Arguments** (optional):
     - `run`
     - `-i`
     - `calculator-mcp`

## Available Tools

- `hello`: Greet someone by name
- `calculate`: Perform basic arithmetic (e.g., "2+2", "10*5/2")

## Usage Examples

After enabling the MCP server, you can use it in Amazon Q:
- "Hello John using the MCP server"
- "Calculate 15 * 8 + 12"
