@echo off
rem Make a project folder for one request (website, game, app, reel, minecraft-paper).
rem Example: new-project.cmd -Kind reel -Name "spring promo"
rem Runs New-CraftProject.ps1 with Windows PowerShell. -ExecutionPolicy Bypass applies to this one
rem process only; it does not change the machine or user policy. Extra arguments are passed on.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-CraftProject.ps1" %*
set CA_EXIT=%ERRORLEVEL%
if not defined CA_NO_PAUSE pause
exit /b %CA_EXIT%
