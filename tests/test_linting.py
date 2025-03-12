import subprocess

def test_linting():
    """Test that the codebase passes flake8 linting."""
    result = subprocess.run(['bash', 'scripts/run_lint.sh'], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting issues found:\n{result.stdout}\n{result.stderr}"
