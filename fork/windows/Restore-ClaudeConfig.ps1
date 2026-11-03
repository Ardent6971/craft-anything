<#
.SYNOPSIS
  Put back a copy of Claude Code's config (.claude.json) that setup saved. Asks first.

.DESCRIPTION
  Usually you want `craft-anything-cli uninstall` instead: it removes only the craft-anything
  entry and skill and leaves the rest of Claude Code's settings as they are now. Use this script
  when you want the whole file exactly as it was before setup. Close Claude Code first.
  The current file is copied to <install root>\backups before it is replaced.

.PARAMETER Backup
  The backup file to restore. Without it, the backups are listed and the newest is offered.

.PARAMETER Yes
  Restore without asking (for scripted tests).
#>
[CmdletBinding()]
param(
    [string]$InstallRoot,
    [string]$Backup,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'CraftAnything.Common.ps1')

$root = Get-CaRoot $InstallRoot
$dir = Join-Path $root 'backups'
$cfg = Get-CaClaudeConfigPath
$cands = @()
if (Test-Path -LiteralPath $dir) { $cands += @(Get-ChildItem -LiteralPath $dir -Filter 'claude.json.*.bak' | Sort-Object Name -Descending) }
$setupCopy = "$cfg.craft-anything.backup"
if (Test-Path -LiteralPath $setupCopy) { $cands += @(Get-Item -LiteralPath $setupCopy) }

if (-not $Backup) {
    if ($cands.Count -eq 0) { Write-CaInfo 'No backups found.'; exit 0 }
    Write-CaInfo 'Backups (newest first; the .craft-anything.backup one is from the very first setup):'
    foreach ($c in $cands) { Write-Host "    $($c.FullName)" }
    $Backup = $cands[0].FullName
}
if (-not (Test-Path -LiteralPath $Backup -PathType Leaf)) { Write-CaFail "No such file: $Backup"; exit 1 }

if (-not $Yes) {
    $answer = Read-Host "Close Claude Code first. Replace $cfg with $Backup? [y/N]"
    if ($answer -notmatch '^(y|yes)$') { Write-CaInfo 'Nothing changed.'; exit 0 }
}
if (Test-Path -LiteralPath $cfg) {
    $keep = Join-Path $dir ("claude.json.{0}.before-restore.bak" -f (Get-Date).ToString('yyyyMMdd-HHmmss'))
    if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir) }
    Copy-Item -LiteralPath $cfg -Destination $keep
    Write-CaOk "Saved the current file as $keep"
}
Copy-Item -LiteralPath $Backup -Destination $cfg -Force
Write-CaOk "Restored $cfg"
exit 0
