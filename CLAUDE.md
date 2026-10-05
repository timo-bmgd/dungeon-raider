# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Engine

- **Godot 4.7.2** (GL Compatibility renderer, 2D). Use **only Godot 4.7 APIs** — never Godot 3
  APIs or syntax, and prefer 4.7 idioms over 4.5 ones.
- The project was written for **4.5** and opened in 4.7, so expect **legacy patterns** (untyped
  vars, `print()` debugging, members in non-canonical order) until the Step 1 migration is done.
  Do not treat legacy style as the target style.

## Roadmap & step rules (read before editing)

Work happens in strict steps. **Stay inside the current step.**

- **Step 0** — environment setup (done: this tooling).
- **Step 1** — audit & finish the 4.5→4.7 migration: fix deprecations/behavior changes, confirm it runs.
- **Step 2** — refactoring only. **No behavior changes, no new features.**

Rules that always hold: a refactor must not change behavior; **never fix unrelated lint warnings
unless asked**; the mechanical style cleanup (`gdformat`, member reordering) is a **Step 2** task,
not something to sneak into Step 0/1 edits.

## Authority

**This file wins** whenever an installed skill or MCP guidance conflicts with it.

## Project structure

- `scripts/` — gameplay logic (`.gd` + `.gd.uid`). `scenes/` — `.tscn` scenes (+ 3 co-located
  scripts: `blacksheep`, `enemy_hooman`). `assets/` — art/audio/tilesets. `build/` — prebuilt
  exports (gitignored). `tools/claude/`, `docs/claude/` — this setup.
- **Single autoload: `SceneManager`** (`scripts/scene_manager.gd`) — top-level scene switcher
  (main_menu ↔ game) holding `game_state`.
- **Two-tier scene flow**: `SceneManager` swaps *top-level* scenes; inside the game,
  `scripts/game_manager.gd` (`load_level`) hot-swaps *level* scenes under `LevelContainer` via
  `ResourceLoader.load(...).instantiate()`. Main scene: `uid://t7mygfmuxnn5`.

## Conventions observed

- `snake_case` files/funcs/vars, `PascalCase` nodes & `class_name`, enums `PascalCase { UPPER }`.
- Node access via unique names (`%ui`) and relative paths (`$"../Player"`).
- Signals are idiomatic 4.x (`signal item_added(item: Item, slot: int)`); wired via explicit
  `connect` / `.emit()`. Only one `class_name` exists (`Item`).
- **Typing is transitional** — ~⅔ of funcs typed, half the vars. When writing *new* code, follow
  xlanstar's "type everything" guidance; do **not** mass-retype legacy code in Steps 0/1.

## Which tool owns which job

| Job | Owner |
|-----|-------|
| Lint checks | **Scony `gdlint`** (config: `gdlintrc`) — the linter of record |
| Formatting / member reordering | **Deferred to Step 2** (`gdformat`). No auto-format in Steps 0/1 |
| Move / rename / delete `.gd` (+`.uid`) | **minami `gdscript-file-manager` + `godot-resource-owners`** (run owners check first) |
| Resave `.tscn/.tres`, regenerate UID/class cache | **minami `godot-resource-resave` / `godot-cache-refresh`** (Step 1+, deliberate) |
| GDScript diagnostics (errors, types, defs, hover) | **twaananen LSP bridge** (native LSP) |
| Scene/node/tilemap edits, run game, input, runtime state, screenshots | **`godot-mcp`** (needs addon + editor open) |
| How to *write* idiomatic 4.7 GDScript/shader/UI/input/tween | **xlanstar skills** (new code only) |
| Godot API lookup | LSP hover first → xlanstar `godot-docs-lookup` → minami `godot-doc-search` for deep dives |

> minami's bundled `gdscript-format` skill uses GDQuest's formatter, **not** `gdlint`. Do not use it
> for linting; `gdlint` is authoritative. Its PreToolUse hook auto-downloads that formatter binary
> on first Bash use — expected, benign.

## MCP tools vs direct file editing

- **Edit files directly** for: creating/editing scenes, nodes, scripts, signal connections
  (write the `.tscn`/`.gd`, then open the scene via MCP and verify), and `project.godot` keys you know.
- **Use `godot-mcp`** for: opening/saving scenes, node property/reparent edits, **tilemap cell data**
  (base64 in `.tscn` — only the MCP can edit it), running the game, input injection, `godot_exec`,
  runtime state/profiler, screenshots, and the editor error log. Verify runtime effects from
  `godot_runtime_state` digests, not screenshots; freeze/step `godot_game_time` for timing.

## Scenes & resources (`.tscn` / `.tres`)

**Never hand-edit `.tscn`/`.tres` in ways that break UIDs or `res://` paths.** For moves/renames use
minami's UID-aware file tools (and `owners.sh` first — `uid://` refs survive a move, `res://` path
literals and `project.godot` autoloads do not). For node/tilemap edits prefer the MCP or the editor.

## Verifying changes

- **Hook** (report-only, non-blocking): editing any `.gd` runs `gdlint` + a headless `--check-only`
  parse (`tools/claude/gd_check.py`) and surfaces findings. It never blocks or modifies files.
- **LSP diagnostics** via the twaananen bridge (needs the editor running with its Language Server on
  port 6005 — `attach` mode).
- **Run the game** through `godot-mcp` (editor must be open with the addon enabled).
- **Tests:** none yet. If added later, use minami's `gdunit4-toolkit` (not installed).
- Manual check from a terminal: `tools/claude/godot.sh --headless --path . --check-only --script <file>`.

## Setup pointers

- Lint rationale & Step 2 plan: `docs/claude/lint-notes.md`.
- Machine-specific env (`GODOT_BIN`, LSP mode/port) lives in `.claude/settings.local.json` (gitignored).
- Godot runs only through `tools/claude/godot.sh` (reads `GODOT_BIN`), never a hard-coded path.
