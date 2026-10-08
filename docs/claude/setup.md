# Project setup — Claude Code environment (Step 0)

How this repo's Claude Code tooling is wired, and how to bring it up each session.
Policy and tool-ownership rules live in [`/CLAUDE.md`](../../CLAUDE.md); lint rationale
in [`lint-notes.md`](lint-notes.md). This file is the operational "how to run it" doc.

## One-time install (already done)

- **gdlint** — `gdtoolkit 4.5.0` installed via **pipx** against Homebrew `python@3.13`
  (not conda base). Binaries at `~/.local/bin/{gdlint,gdformat}`. Re-create with:
  `pipx install --python /opt/homebrew/opt/python@3.13/bin/python3.13 'gdtoolkit==4.*'`.
- **Plugins** (project scope, in `.claude/settings.json`): `gdscript-toolkit@claude-godot-tools`,
  `godot-skills@godot-skills`, `gdscript@claude-code-gdscript` (LSP bridge).
- **MCP** (`.mcp.json`): `godot-mcp` via `npx -y @satelliteoflove/godot-mcp`, telemetry off.
  Editor addon installed at `addons/godot_mcp/` (v4.1.11) — enable it in the editor (below).
- **Machine env** (gitignored `.claude/settings.local.json`): `GODOT_BIN`, `GODOT_EDITOR_PATH`,
  `GODOT_LSP_MODE=attach`, `GODOT_LSP_HOST=127.0.0.1`, `GODOT_LSP_PORT=6005`.

## Per-session startup (do this every time)

1. **Launch the Godot 4.7 editor** with the LSP on 6005, and keep it open:
   ```
   /Applications/Godot.app/Contents/MacOS/Godot --editor --path /Users/timo/Projects/dungeon-raider --lsp-port 6005
   ```
2. **Enable the MCP addon** (first time only, then it stays on):
   Project → Project Settings → Plugins → **Godot MCP**. It listens on `127.0.0.1:6550`.
3. **Start Claude Code from the project root** so project plugins/MCP/hooks load:
   `cd /Users/timo/Projects/dungeon-raider && claude`.

## Verify it's all up

```bash
nc -z 127.0.0.1 6005 && echo "LSP OPEN"      # editor Language Server (attach mode)
```
- **MCP**: `godot_project addon_status` → `connected:true`, `versions_match:true`.
- **LSP**: `LSP documentSymbol` on any `.gd` returns a typed outline.
- **Hook**: editing any `.gd` surfaces `[gd_check] …` findings (report-only, never blocks).

## Gotchas

- **LSP is `attach` mode** — it needs the editor open and serving 6005. If `documentSymbol`
  times out, confirm `nc -z 127.0.0.1 6005` is OPEN; a clean editor relaunch with `--lsp-port 6005`
  fixes a server that didn't bind. (Editor Settings → Network → Connection → Network Mode must be
  **Online**.) Fallback: set `GODOT_LSP_MODE=auto` in `settings.local.json` to self-launch a
  headless LSP backend, then restart Claude Code.
- **Duplicate `godot-mcp` server** after a restart: a stale server from the previous session may
  linger and spam the editor log with "another client is already connected". Harmless; clears on a
  full Claude Code restart or by killing the stale PID.
- **First Bash call** each session triggers minami's PreToolUse hook, which downloads GDQuest's
  `gdscript-formatter` binary once. Expected; we don't use it for linting (`gdlint` is authoritative).
- **Run Godot only via `tools/claude/godot.sh`** (reads `GODOT_BIN`), never a hard-coded path.

## Step 0 verification (2026-10-06)

MCP ✅ · LSP ✅ · plugins/skills discovered ✅ · report-only hook ✅ — all green on branch
`setup/claude-step0`.
