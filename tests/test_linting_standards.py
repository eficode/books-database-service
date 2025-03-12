import subprocess

def test_linting_standards():
    """Test to ensure the codebase passes all linting checks."""
    result = subprocess.run(["./scripts/run_lint.sh"], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting failed:\n{result.stdout}\n{result.stderr}"
