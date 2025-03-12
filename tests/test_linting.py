import subprocess

def test_linting():
    """Test to ensure code adheres to linting standards."""
    result = subprocess.run(['flake8', '.'], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting issues found:\n{result.stdout}"

def test_run_lint_script():
    """Test to ensure the linting script runs without errors."""
    result = subprocess.run(['./scripts/run_lint.sh'], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting script failed with error: {result.stderr}"
