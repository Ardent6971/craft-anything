@echo off
rem Read-only check of this PC (changes nothing).
rem Runs Check-CraftAnything.ps1 with Windows PowerShell. -ExecutionPolicy Bypass applies to this one
rem process only; it does not change the machine or user policy. Extra arguments are passed on.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-CraftAnything.ps1" %*
set CA_EXIT=%ERRORLEVEL%
if not defined CA_NO_PAUSE pause
exit /b %CA_EXIT%
