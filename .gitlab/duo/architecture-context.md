# Architecture Context

## System Architecture

### Components
- **books-service**: FastAPI application exposing REST endpoints
- **books-database**: SQLite database with book records
- **frontend**: React SPA with component-based UI
- **robot-tests**: Browser automation tests using Robot Framework

## Data Flows

- Frontend makes API calls to backend for CRUD operations
- Backend validates requests and interacts with database
- Changes are reflected immediately in the UI