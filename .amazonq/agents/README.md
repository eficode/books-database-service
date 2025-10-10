# QA Test Runner Agent

Automated Robot Framework test execution with smart reporting.

## Usage

```bash
# Run all tests (will prompt for test suite selection)
python .amazonq/agents/qa-runner.py all

# Run specific test suite
python .amazonq/agents/qa-runner.py all --sonnet-4.5
python .amazonq/agents/qa-runner.py all --sonnet-4
python .amazonq/agents/qa-runner.py all --both

# Run with rerun on failures
python .amazonq/agents/qa-runner.py all --rerun --sonnet-4.5

# Run smoke tests only
python .amazonq/agents/qa-runner.py all --smoke --sonnet-4.5

# Run changed tests only
python .amazonq/agents/qa-runner.py all --changed

# Run UI tests
python .amazonq/agents/qa-runner.py ui --sonnet-4.5

# Run API tests
python .amazonq/agents/qa-runner.py api --sonnet-4.5

# Run with parallel execution
python .amazonq/agents/qa-runner.py all --parallel --sonnet-4.5
```

## Amazon Q Integration

Use natural language commands:
- "Run all tests"
- "Run smoke tests"
- "Rerun failed tests"
- "Run changed tests only"
- "Run UI tests"
- "Run API tests"

The agent will:
1. Check Poetry and install deps if needed
2. Read qa-memory/ for context
3. Execute tests with appropriate options
4. Parse output.xml for results
5. Generate markdown summary with artifacts
6. Provide quick action commands

## Output

Results saved to: `robot_results/<scope>/<YYYYMMDD_HHMMSS>/`

Artifacts:
- `output.xml` - Test results
- `report.html` - HTML report
- `log.html` - Detailed log
- `merged-output.xml` - Merged results (if rerun)
