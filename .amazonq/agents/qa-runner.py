#!/usr/bin/env python3
"""QA Test Runner Agent for Robot Framework"""
import os
import subprocess
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple

class QARunner:
    def __init__(self, workspace: str = "."):
        self.workspace = Path(workspace)
        self.test_roots = ["robot_tests_claude_sonnet_4_5", "robot_tests_claude_sonnet_4"]
        self.results_base = self.workspace / "robot_results"
        self.memory_path = self.workspace / "qa-memory"
        
    def run(self, scope: str = "all", **kwargs) -> Dict:
        """Main entry point"""
        self._ensure_poetry()
        self._read_memory()
        
        # Ask which test suite to run if not specified
        if scope == "all" and "test_suite" not in kwargs:
            print("\n🤖 Select test suite:")
            print("  1️⃣  sonnet_4_5 (recommended)")
            print("  2️⃣  sonnet_4")
            print("  3️⃣  both")
            choice = input("Choice (1-3): ").strip()
            
            if choice == "1":
                kwargs["test_suite"] = "sonnet_4_5"
            elif choice == "2":
                kwargs["test_suite"] = "sonnet_4"
            elif choice == "3":
                kwargs["test_suite"] = "both"
            else:
                kwargs["test_suite"] = "sonnet_4_5"  # default
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        suite_name = kwargs.get("test_suite", "sonnet_4_5")
        outdir = self.results_base / suite_name / timestamp
        outdir.mkdir(parents=True, exist_ok=True)
        
        paths = self._resolve_paths(scope, kwargs.get("changed_only", False), kwargs.get("test_suite", "sonnet_4_5"))
        cmd = self._build_command(outdir, paths, **kwargs)
        
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=self.workspace)
        
        if kwargs.get("rerun_failed") and (outdir / "output.xml").exists():
            self._rerun_failed(outdir, paths)
            self._merge_results(outdir)
        
        return self._generate_report(outdir, cmd, result.returncode)
    
    def _ensure_poetry(self):
        if subprocess.run(["poetry", "--version"], capture_output=True).returncode != 0:
            raise RuntimeError("Poetry not found")
        
        if not (self.workspace / "poetry.lock").exists():
            subprocess.run(["poetry", "install", "--no-interaction"], capture_output=True, cwd=self.workspace, check=True)
    
    def _read_memory(self):
        index = self.memory_path / "index.md"
        # Silent memory check
    
    def _resolve_paths(self, scope: str, changed_only: bool, test_suite: str = "sonnet_4_5") -> List[str]:
        if changed_only:
            return self._get_changed_tests()
        
        if test_suite == "sonnet_4":
            root = self.test_roots[1]
        elif test_suite == "both":
            return self.test_roots
        else:
            root = self.test_roots[0]
        
        if scope in ["ui", "api"]:
            return [f"{root}/books_{scope}.robot"]
        return [root]
    
    def _get_changed_tests(self) -> List[str]:
        result = subprocess.run(["git", "diff", "--name-only", "HEAD"], capture_output=True, text=True, cwd=self.workspace)
        changed = [f for f in result.stdout.splitlines() if f.endswith(".robot")]
        return changed if changed else [self.test_roots[0]]
    
    def _build_command(self, outdir: Path, paths: List[str], **kwargs) -> List[str]:
        use_pabot = kwargs.get("parallel", False)
        cmd = ["poetry", "run", "pabot" if use_pabot else "robot"]
        
        if use_pabot:
            cmd.extend(["--processes", "auto"])
        
        cmd.extend(["-d", str(outdir), "--output", "output.xml", "--report", "report.html", "--log", "log.html"])
        
        if kwargs.get("suite"):
            cmd.extend(["-s", kwargs["suite"]])
        if kwargs.get("test"):
            cmd.extend(["-t", kwargs["test"]])
        if kwargs.get("include_tags"):
            for tag in kwargs["include_tags"]:
                cmd.extend(["-i", tag])
        if kwargs.get("exclude_tags"):
            for tag in kwargs["exclude_tags"]:
                cmd.extend(["-e", tag])
        if kwargs.get("variables"):
            for k, v in kwargs["variables"].items():
                cmd.extend(["-v", f"{k}:{v}"])
        if kwargs.get("exitonfailure"):
            cmd.append("--exitonfailure")
        if kwargs.get("xunit"):
            cmd.extend(["--xunit", "xunit.xml"])
        if kwargs.get("slim_logs"):
            cmd.extend(["--removekeywords", "wuks"])
        
        cmd.extend(paths)
        return cmd
    
    def _rerun_failed(self, outdir: Path, paths: List[str]):
        cmd = ["poetry", "run", "robot", "--rerunfailed", str(outdir / "output.xml"), "--output", str(outdir / "rerun-output.xml")] + paths
        subprocess.run(cmd, capture_output=True, cwd=self.workspace)
    
    def _merge_results(self, outdir: Path):
        cmd = ["poetry", "run", "rebot", "--merge", "--output", str(outdir / "merged-output.xml"), str(outdir / "output.xml"), str(outdir / "rerun-output.xml")]
        subprocess.run(cmd, capture_output=True, cwd=self.workspace)
    
    def _generate_report(self, outdir: Path, cmd: List[str], returncode: int) -> Dict:
        xml_file = outdir / "merged-output.xml" if (outdir / "merged-output.xml").exists() else outdir / "output.xml"
        
        if not xml_file.exists():
            return {"error": "No output.xml", "returncode": returncode}
        
        stats, failures = self._parse_xml(xml_file)
        
        report = {
            "outdir": str(outdir.relative_to(self.workspace)),
            "command": " ".join(cmd),
            "returncode": returncode,
            "stats": stats,
            "failures": failures[:10],
            "artifacts": {
                "log": str((outdir / "log.html").relative_to(self.workspace)),
                "report": str((outdir / "report.html").relative_to(self.workspace)),
                "xml": str(xml_file.relative_to(self.workspace))
            }
        }
        
        self._print_report(report)
        return report
    
    def _parse_xml(self, xml_file: Path) -> Tuple[Dict, List[Dict]]:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        stats_elem = root.find(".//statistics/total/stat")
        stats = {
            "total": int(stats_elem.get("pass", 0)) + int(stats_elem.get("fail", 0)),
            "passed": int(stats_elem.get("pass", 0)),
            "failed": int(stats_elem.get("fail", 0)),
            "skipped": int(stats_elem.get("skip", 0)),
        }
        
        suite = root.find("suite")
        if suite is not None:
            status = suite.find("status")
            if status is not None:
                elapsed = status.get("elapsed", "0")
                stats["duration"] = f"{int(elapsed) // 1000}s"
        
        stats["suites"] = len(root.findall(".//suite[@source]"))
        
        failures = []
        for test in root.findall(".//test"):
            status = test.find("status")
            if status is not None and status.get("status") == "FAIL":
                suite_name = test.find("..").get("name", "Unknown")
                test_name = test.get("name", "Unknown")
                msg = status.text or "No error"
                failures.append({"suite": suite_name, "test": test_name, "error": msg.split("\n")[0][:100]})
        
        return stats, failures
    
    def _print_report(self, report: Dict):
        stats = report["stats"]
        pass_rate = (stats['passed'] / stats['total'] * 100) if stats['total'] > 0 else 0
        
        print("\n╔═══════════════════════════════════════════════════════════")
        print("║")
        
        if stats['failed'] == 0:
            print("║  🎉 ✨ ALL TESTS PASSED! ✨ 🎉")
            print("║")
            print(f"║  ✅ {stats['passed']}/{stats['total']} tests | {pass_rate:.0f}% success | ⚡ {stats.get('duration', '0s')}")
        else:
            print("║  ⚠️  TESTS FAILED ⚠️")
            print("║")
            print(f"║  ✅ {stats['passed']} passed | ❌ {stats['failed']} failed | ⚡ {stats.get('duration', '0s')}")
        
        print("║")
        print("╠═══════════════════════════════════════════════════════════")
        
        if report["failures"]:
            print("║")
            print("║  💥 FAILURES:")
            print("║")
            for i, f in enumerate(report["failures"][:5], 1):
                print(f"║  {i}. {f['suite']} :: {f['test']}")
                print(f"║     {f['error'][:80]}")
                print("║")
            print("╠═══════════════════════════════════════════════════════════")
        
        print("║")
        print(f"║  📁 {report['outdir']}")
        print("║")
        print(f"║  📊 [View Report]({report['artifacts']['report']})")
        print(f"║  📋 [View Log]({report['artifacts']['log']})")
        print("║")
        print("╚═══════════════════════════════════════════════════════════\n")


if __name__ == "__main__":
    import sys
    runner = QARunner()
    scope = sys.argv[1] if len(sys.argv) > 1 else "all"
    kwargs = {}
    if "--parallel" in sys.argv: kwargs["parallel"] = True
    if "--rerun" in sys.argv: kwargs["rerun_failed"] = True
    if "--changed" in sys.argv: kwargs["changed_only"] = True
    if "--smoke" in sys.argv: kwargs["include_tags"] = ["smoke"]
    if "--sonnet-4" in sys.argv: kwargs["test_suite"] = "sonnet_4"
    if "--sonnet-4.5" in sys.argv: kwargs["test_suite"] = "sonnet_4_5"
    if "--both" in sys.argv: kwargs["test_suite"] = "both"
    runner.run(scope, **kwargs)
