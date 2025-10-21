# GitHub Copilot Instructions

This directory contains context and guidelines for GitHub Copilot to provide better assistance for the books database service project.

## Files Overview

- **`architecture.md`** - System architecture and component relationships
- **`context.md`** - Project domain knowledge and business requirements  
- **`standards.md`** - Code quality standards and style guidelines
- **`review-guide.md`** - Code review checklist and quality gates
- **`workflow.md`** - Development processes and deployment procedures
- **`glossary.md`** - Project terminology and definitions

## Usage Instructions

When GitHub Copilot assists with this project, it should:

1. **Follow Architecture Patterns** described in `architecture.md`
2. **Understand Domain Context** from `context.md` for accurate suggestions
3. **Adhere to Code Standards** specified in `standards.md`
4. **Apply Review Guidelines** from `review-guide.md` for quality assurance
5. **Respect Workflow Processes** outlined in `workflow.md`
6. **Use Consistent Terminology** defined in `glossary.md`

## Key Project Characteristics

- **Technology Stack**: FastAPI (Python), React, SQLite, Robot Framework
- **Architecture**: RESTful API with SPA frontend
- **Testing Strategy**: Unit, integration, and E2E testing
- **Deployment**: Containerized with Docker
- **Domain**: Personal book collection management

## Code Generation Guidelines

When generating code, GitHub Copilot should:

- Use proper error handling and validation
- Include appropriate type hints and documentation
- Follow established patterns in the existing codebase
- Consider test coverage requirements
- Maintain consistency with project standards

## Assistance Areas

GitHub Copilot can help with:

- Writing new features following established patterns
- Creating comprehensive tests for new functionality
- Refactoring code while maintaining functionality
- Generating documentation and API specifications
- Suggesting performance optimizations
- Identifying potential security issues

This context enables GitHub Copilot to provide more accurate, consistent, and project-appropriate assistance.