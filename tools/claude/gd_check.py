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


def autoload_names(root: Path) -> set:
    """Names registered in project.godot [autoload]. Isolated `--check-only`
    does not register autoload singletons, so references to them surface as
    false 'Identifier not found: <Autoload>' errors that we filter out."""
    names = set()
    pg = root / "project.godot"
    if not pg.exists():
        return names
    in_autoload = False
    try:
        for line in pg.read_text().splitlines():
            s = line.strip()
            if s.startswith("["):
                in_autoload = (s == "[autoload]")
            elif in_autoload and "=" in s and not s.startswith(";"):
                names.add(s.split("=", 1)[0].strip())
    except Exception:
        pass
    return names


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

            # Filter autoload false positives (see autoload_names). Drop the
            # "Identifier not found: <autoload>" lines, and drop the resulting
            # "Compilation failed" cascade when nothing else actually failed.
            autoloads = autoload_names(root)

            def is_fp(ln):
                return any(("Identifier not found: %s" % a) in ln for a in autoloads)

            def is_cascade(ln):
                return "Failed to load script" in ln and "Compilation failed" in ln

            fp = [ln for ln in errs if is_fp(ln)]
            non_fp = [ln for ln in errs if not is_fp(ln)]
            real = [ln for ln in non_fp if not is_cascade(ln)]
            report_errs = [] if (fp and not real) else non_fp

            if report_errs:
                sections.append("godot --check-only:\n"
                                + "\n".join("  " + ln for ln in report_errs))
        except Exception:
            pass

    if sections:
        emit(f"[gd_check] {rel} (report-only; does not block):\n"
             + "\n".join(sections))
    sys.exit(0)


if __name__ == "__main__":
    main()
