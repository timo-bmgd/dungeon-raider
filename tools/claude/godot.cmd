@echo off
rem Run the Godot binary pointed to by %GODOT_BIN% (set in .claude\settings.local.json).
setlocal
if "%GODOT_BIN%"=="" (
  echo godot.cmd: GODOT_BIN is not set. Set it in .claude\settings.local.json ^(env block^). 1>&2
  exit /b 2
)
if not exist "%GODOT_BIN%" (
  echo godot.cmd: GODOT_BIN ^(%GODOT_BIN%^) not found. 1>&2
  exit /b 2
)
"%GODOT_BIN%" %*
exit /b %ERRORLEVEL%
