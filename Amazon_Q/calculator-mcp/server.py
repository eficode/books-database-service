#!/usr/bin/env python3
import json
import sys
from typing import Any, Dict

def handle_request(request: Dict[str, Any]) -> Dict[str, Any]:
    method = request.get("method")
    
    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {}
                },
                "serverInfo": {
                    "name": "calculator-mcp",
                    "version": "1.0.0"
                }
            }
        }
    
    elif method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": {
                "tools": [
                    {
                        "name": "calculate",
                        "description": "Perform basic arithmetic calculations",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "expression": {
                                    "type": "string",
                                    "description": "Mathematical expression to evaluate (e.g., '2+2', '10*5')"
                                }
                            },
                            "required": ["expression"]
                        }
                    },
                    {
                        "name": "hello",
                        "description": "Say hello with a custom message",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "name": {
                                    "type": "string",
                                    "description": "Name to greet"
                                }
                            },
                            "required": ["name"]
                        }
                    }
                ]
            }
        }
    
    elif method == "tools/call":
        params = request.get("params", {})
        tool_name = params.get("name")
        arguments = params.get("arguments", {})
        
        if tool_name == "calculate":
            try:
                expression = arguments.get("expression", "")
                # Safe evaluation of basic math expressions
                allowed_chars = set("0123456789+-*/.() ")
                if all(c in allowed_chars for c in expression):
                    result = eval(expression)
                    content = f"Result: {result}"
                else:
                    content = "Error: Invalid characters in expression"
            except Exception as e:
                content = f"Error: {str(e)}"
        
        elif tool_name == "hello":
            name = arguments.get("name", "World")
            content = f"Hello, {name}! 👋"
        
        else:
            content = f"Unknown tool: {tool_name}"
        
        return {
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": {
                "content": [
                    {
                        "type": "text",
                        "text": content
                    }
                ]
            }
        }
    
    return {
        "jsonrpc": "2.0",
        "id": request.get("id"),
        "error": {
            "code": -32601,
            "message": "Method not found"
        }
    }

def main():
    for line in sys.stdin:
        try:
            request = json.loads(line.strip())
            response = handle_request(request)
            print(json.dumps(response))
            sys.stdout.flush()
        except Exception as e:
            error_response = {
                "jsonrpc": "2.0",
                "id": None,
                "error": {
                    "code": -32700,
                    "message": f"Parse error: {str(e)}"
                }
            }
            print(json.dumps(error_response))
            sys.stdout.flush()

if __name__ == "__main__":
    main()
