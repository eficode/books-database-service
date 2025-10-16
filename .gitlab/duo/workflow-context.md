# Workflow Context

## Development Workflow

### Branch Management
- Feature branches are created from main
- MRs require passing CI pipeline and code review
- Hotfixes are done directly on main with MR

### Code Review Requirements
- UI changes need screenshots in MR description
- Database changes require migration scripts
- API changes must be documented in OpenAPI spec
- Robot Framework tests cover critical user flows

### Quality Assurance
- Regularly update dependencies and address security alerts
- Manual testing in staging before production deployment

### Deployment Process
- Merge to main triggers deployment to staging
- Manual testing in staging before production deployment

### Commit Standards
- Use semantic commit messages (feat, fix, docs, style, refactor, test, chore)
- Tag releases with version numbers (vX.Y.Z)