from fastapi import FastAPI, HTTPException
import httpx
import os
from typing import Optional, Dict, Any, List

class BraveSearchMCP:
    def __init__(self, app: FastAPI):
        """Initialize the Brave Search MCP integration with FastAPI app."""
        self.app = app
        # Try to get from environment, default to None if not available
        self.api_key = os.environ.get("BRAVE_API_KEY")
        self.search_url = "https://api.search.brave.com/res/v1/web/search"
        self.setup_routes()
    
    def setup_routes(self):
        """Setup the MCP routes."""
        @self.app.get(
            "/mcp/brave/search", 
            operation_id="brave_search", 
            description="Search the web using Brave Search API"
        )
        async def brave_search(query: str, count: int = 10) -> Dict[str, Any]:
            """
            Search the web using Brave Search API.
            
            Args:
                query: The search query string
                count: Number of results to return (default: 10)
            
            Returns:
                Web search results from Brave
            """
            if not self.api_key:
                raise HTTPException(status_code=500, detail="Brave API key not configured")
            
            headers = {
                "Accept": "application/json",
                "X-Subscription-Token": self.api_key
            }
            
            params = {
                "q": query,
                "count": count
            }
            
            try:
                async with httpx.AsyncClient() as client:
                    response = await client.get(
                        self.search_url,
                        headers=headers,
                        params=params
                    )
                    
                    if response.status_code != 200:
                        raise HTTPException(
                            status_code=response.status_code,
                            detail=f"Brave Search API error: {response.text}"
                        )
                    
                    data = response.json()
                    
                    # Format response in a way that's compatible with Claude MCP expectations
                    return self._format_results(data, query)
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Failed to fetch results: {str(e)}")
    
    def _format_results(self, data: Dict[str, Any], query: str) -> Dict[str, Any]:
        """
        Format Brave search results to match Claude MCP format.
        
        Args:
            data: Raw Brave API response
            query: Original search query
            
        Returns:
            Formatted results in Claude MCP format
        """
        formatted_results = []
        
        # Process web search results
        if "web" in data and "results" in data["web"]:
            for result in data["web"]["results"]:
                formatted_result = {
                    "title": result.get("title", ""),
                    "url": result.get("url", ""),
                    "snippet": result.get("description", "")
                }
                
                formatted_results.append(formatted_result)
        
        return {
            "results": formatted_results,
            "query": query
        }

def setup_mcp_server(app: FastAPI):
    """Setup the MCP server with the given FastAPI app."""
    BraveSearchMCP(app)