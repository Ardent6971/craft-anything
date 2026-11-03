@echo off
rem Put back a saved copy of Claude Code's config (asks first).
rem Runs Restore-ClaudeConfig.ps1 with Windows PowerShell. -ExecutionPolicy Bypass applies to this one
rem process only; it does not change the machine or user policy. Extra arguments are passed on.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Restore-ClaudeConfig.ps1" %*
set CA_EXIT=%ERRORLEVEL%
if not defined CA_NO_PAUSE pause
exit /b %CA_EXIT%
