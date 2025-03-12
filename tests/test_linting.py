import subprocess

def test_linting():
    """Test to ensure code adheres to linting standards."""
    result = subprocess.run(['flake8', '.'], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting issues found:\n{result.stdout}"
