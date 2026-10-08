# Lint notes (gdlint)

Linter of record: **Scony `gdtoolkit` / `gdlint`** (installed via pipx, pinned to `gdtoolkit==4.*`; measured against **4.5.0**). Config lives in [`/gdlintrc`](../../gdlintrc).

> minami's `gdscript-toolkit` plugin bundles a *different* formatter (GDQuest's `gdscript-formatter`). It is **not** used for linting in Steps 0–1. `gdlint` is authoritative. See CLAUDE.md.

## Baseline (2026-10-05, Godot 4.5→4.7 migration, pre-cleanup)

Running default-rule `gdlint` on all 23 `.gd` files produced **122 findings**:

| Rule | Hits | Disabled now? | Why |
|------|-----:|:-------------:|-----|
| `trailing-whitespace` | 80 | **yes** | Blank lines carry trailing tabs throughout the legacy code. Purely cosmetic; `gdformat` rewrites it mechanically. Keeping it on buries real findings 20:1. |
| `class-definitions-order` | 38 | **yes** | Legacy member ordering (signals after `@onready` vars, consts mid-file, etc.). Fixing it means reordering every script — a Step 2 refactor, not a Step 0/1 edit. |
| `class-variable-name` | 3 | no | `GENERATIONS`, `ITEM_COUNT`, `ENEMY_COUNT` in `tile_map_layer.gd` are UPPER-case `var`s. Genuine signal, low volume — likely want `const` or `@export` in Step 2. |
| `unused-argument` | 1 | no | Unused `body` in `item.gd:82`. Prefix with `_` in Step 2. |

Disabling the top two leaves **4 genuine findings** — a quiet enough baseline that the report-only hook surfaces real issues instead of noise.

## Why report-only (not blocking) until Step 2

- Legacy 4.5 codebase mid-migration; blocking edits on pre-existing findings would obstruct Step 1.
- `gdlint` reports at file scope, so "block on changed lines only" needs fragile diff plumbing.
- Project rule: never fix unrelated lint warnings unless asked — surface, don't gate.

## Step 2 plan (do NOT do these in Steps 0–1)

1. Run `gdformat` across `scripts/` and `scenes/` to clear `trailing-whitespace` and reflow.
2. Reorder class members, then **remove `class-definitions-order` from `disable:`** in `gdlintrc`.
3. Address the 4 residual findings (`const`/`@export`/`_`-prefix).
4. Re-enable `trailing-whitespace`; consider switching the hook to blocking once the tree is clean.

## Rule reference

`gdlint --dump-default-config` prints every rule and its default. Each `disable:` entry in `gdlintrc` must stay documented in the table above.
