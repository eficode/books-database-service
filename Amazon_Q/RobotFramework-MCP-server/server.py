#!/usr/bin/env python3
"""
MCP server to run Robot Framework tests (Browser/Chromium + Requests) - TEST VERSION
Tools:
  - run_suite(suite_path="/tests", include_tags=None, exclude_tags=None, variables=None)
  - run_test_by_name(test_name, suite_path="/tests", variables=None)
  - list_tests(suite_path="/tests")
Mount your repo tests at /tests (read-only) and results at /results.
"""
import os
import shlex
import subprocess
from pathlib import Path
from typing import Optional, Dict, List

from mcp.server.fastmcp import FastMCP  # official python-sdk FastMCP

APP_NAME = "rf-mcp-test"
DEFAULT_TESTS = os.getenv("RF_TESTS_DIR", "/tests")
DEFAULT_RESULTS = os.getenv("ROBOT_OUTPUT_DIR", "/tmp/results")

mcp = FastMCP(APP_NAME)


def _robot_cmd(
    suite_path: str,
    test_name: Optional[str] = None,
    include_tags: Optional[str] = None,
    exclude_tags: Optional[str] = None,
    variables: Optional[Dict[str, str]] = None,
) -> List[str]:
    Path(DEFAULT_RESULTS).mkdir(parents=True, exist_ok=True)
    cmd = ["robot", "--outputdir", DEFAULT_RESULTS]
    merged_vars = {"BROWSER": "chromium", "HEADLESS": "true", **(variables or {})}
    for k, v in merged_vars.items():
        cmd += ["-v", f"{k}:{v}"]
    if include_tags:
        cmd += ["-i", include_tags]
    if exclude_tags:
        cmd += ["-e", exclude_tags]
    if test_name:
        cmd += ["-t", test_name]
    cmd += [suite_path]
    return cmd


def _run(cmd: List[str]) -> Dict:
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return {
        "returncode": p.returncode,
        "command": " ".join(shlex.quote(c) for c in cmd),
        "stdout": p.stdout[-10000:],  # tail to keep responses small
        "stderr": p.stderr[-10000:],
        "artifacts": {
            "output_xml": str(Path(DEFAULT_RESULTS) / "output.xml"),
            "log_html": str(Path(DEFAULT_RESULTS) / "log.html"),
            "report_html": str(Path(DEFAULT_RESULTS) / "report.html"),
        },
    }


@mcp.tool()
def run_suite(
    suite_path: str = DEFAULT_TESTS,
    include_tags: Optional[str] = None,
    exclude_tags: Optional[str] = None,
    variables: Optional[Dict[str, str]] = None,
) -> Dict:
    """Run an entire Robot Framework suite/folder."""
    return _run(
        _robot_cmd(
            suite_path=suite_path,
            include_tags=include_tags,
            exclude_tags=exclude_tags,
            variables=variables,
        )
    )


@mcp.tool()
def run_test_by_name(
    test_name: str,
    suite_path: str = DEFAULT_TESTS,
    variables: Optional[Dict[str, str]] = None,
) -> Dict:
    """Run a single test by name (or pattern)."""
    return _run(
        _robot_cmd(
            suite_path=suite_path,
            test_name=test_name,
            variables=variables,
        )
    )


@mcp.tool()
def list_tests(suite_path: str = DEFAULT_TESTS) -> Dict:
    """List test case long names under suite_path."""
    try:
        from robot.api import TestSuiteBuilder
        suite = TestSuiteBuilder().build(suite_path)
        names: List[str] = []
        def walk(s):
            for t in s.tests:
                names.append(t.longname)
            for child in s.suites:
                walk(child)
        walk(suite)
        return {"count": len(names), "tests": names}
    except Exception as e:
        return {"error": str(e), "hint": "Check suite_path and Robot syntax."}


if __name__ == "__main__":
    # STDIO is the default transport for FastMCP; just run()
    mcp.run()