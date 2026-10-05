#!/usr/bin/env bash
# Run the Godot binary pointed to by $GODOT_BIN.
#
# GODOT_BIN is set per-machine in .claude/settings.local.json (env block,
# gitignored) so this wrapper stays portable. Every Claude Code hook/script
# that needs Godot must go through this wrapper, never a hard-coded path.
#
# Usage: tools/claude/godot.sh [godot args...]
set -euo pipefail

if [[ -z "${GODOT_BIN:-}" ]]; then
  echo "godot.sh: GODOT_BIN is not set. Add it to .claude/settings.local.json (env block), e.g. /Applications/Godot.app/Contents/MacOS/Godot" >&2
  exit 2
fi

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "godot.sh: GODOT_BIN ($GODOT_BIN) is not an executable file." >&2
  exit 2
fi

exec "$GODOT_BIN" "$@"
