# Run the Godot binary pointed to by $env:GODOT_BIN (set in .claude/settings.local.json).
$ErrorActionPreference = "Stop"
if (-not $env:GODOT_BIN) {
    Write-Error "godot.ps1: GODOT_BIN is not set. Set it in .claude/settings.local.json (env block)."
    exit 2
}
if (-not (Test-Path -LiteralPath $env:GODOT_BIN)) {
    Write-Error "godot.ps1: GODOT_BIN ($env:GODOT_BIN) not found."
    exit 2
}
& $env:GODOT_BIN @args
exit $LASTEXITCODE
