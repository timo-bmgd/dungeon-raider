#!/usr/bin/env python3
"""PostToolUse hook: report-only gdlint + headless Godot syntax check for .gd files.

Wired to Write/Edit/MultiEdit in .claude/settings.json. Reads the hook payload on
stdin, and for a single edited .gd file inside the project:

  1. runs `gdlint` (config: /gdlintrc),
  2. runs a headless `--check-only` parse via tools/claude/godot.sh,

then surfaces any findings to Claude via hookSpecificOutput.additionalContext.

Report-only by design (Steps 0-1): it ALWAYS exits 0, never blocks an edit, never
writes files, never opens the editor. If there are no findings it emits nothing.
See docs/claude/lint-notes.md and CLAUDE.md.
"""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Markers that indicate a real problem in `godot --check-only` stderr.
GODOT_ERROR_MARKERS = ("SCRIPT ERROR", "Parse Error", "ERROR: Failed to load")
TIMEOUT_S = 15


def emit(context: str) -> None:
    """Print a non-blocking PostToolUse additionalContext payload, then exit 0."""
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": context,
        }
    }))
    sys.exit(0)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        sys.exit(0)  # malformed payload -> stay silent, never block

    file_path = (payload.get("tool_input") or {}).get("file_path")
    if not file_path:
        sys.exit(0)

    root = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")).resolve()
    target = Path(file_path)
    if not target.is_absolute():
        target = (root / target)
    target = target.resolve()

    # Only .gd files that still exist and live inside the project.
    if target.suffix != ".gd" or not target.is_file():
        sys.exit(0)
    try:
        rel = target.relative_to(root)
    except ValueError:
        sys.exit(0)

    sections = []

    # 1) gdlint (discovers /gdlintrc via cwd=root). Non-zero exit = findings.
    gdlint = shutil.which("gdlint") or str(Path.home() / ".local/bin/gdlint")
    if Path(gdlint).exists():
        try:
            res = subprocess.run(
                [gdlint, str(rel)], cwd=str(root),
                capture_output=True, text=True, timeout=TIMEOUT_S,
            )
            if res.returncode != 0:
                out = (res.stdout + res.stderr).strip()
                lines = [ln for ln in out.splitlines()
                         if ln.strip() and not ln.startswith("Failure:")]
                if lines:
                    sections.append("gdlint:\n" + "\n".join("  " + ln for ln in lines))
        except Exception:
            pass  # tooling hiccup must never block an edit

    # 2) headless parse via the GODOT_BIN wrapper. Exit code is unreliable here,
    #    so detect errors by scanning stderr for known markers.
    wrapper = root / "tools/claude/godot.sh"
    if wrapper.exists() and os.environ.get("GODOT_BIN"):
        try:
            res = subprocess.run(
                [str(wrapper), "--headless", "--path", str(root),
                 "--check-only", "--script", str(target)],
                cwd=str(root), capture_output=True, text=True, timeout=TIMEOUT_S,
            )
            errs = [ln for ln in (res.stdout + res.stderr).splitlines()
                    if any(m in ln for m in GODOT_ERROR_MARKERS)]
            if errs:
                sections.append("godot --check-only:\n"
                                + "\n".join("  " + ln for ln in errs))
        except Exception:
            pass

    if sections:
        emit(f"[gd_check] {rel} (report-only; does not block):\n"
             + "\n".join(sections))
    sys.exit(0)


if __name__ == "__main__":
    main()
