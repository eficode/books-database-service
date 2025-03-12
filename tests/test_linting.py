import subprocess

def test_linting():
    """Test to ensure the linting script runs without errors."""
    result = subprocess.run(["bash", "scripts/run_lint.sh"], capture_output=True, text=True)
    assert result.returncode == 0, f"Linting failed:\n{result.stdout}\n{result.stderr}"
