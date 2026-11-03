@echo off
rem Install Craft Anything and connect it to Claude Code (asks before changing Claude Code's config).
rem Runs Install-CraftAnything.ps1 with Windows PowerShell. -ExecutionPolicy Bypass applies to this one
rem process only; it does not change the machine or user policy. Extra arguments are passed on.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-CraftAnything.ps1" %*
set CA_EXIT=%ERRORLEVEL%
if not defined CA_NO_PAUSE pause
exit /b %CA_EXIT%
