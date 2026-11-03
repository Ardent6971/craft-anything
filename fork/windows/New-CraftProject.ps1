<#
.SYNOPSIS
  Make a project folder for one request, with an intake sheet and (for external workflows) the
  starter files. Never overwrites an existing folder.

.PARAMETER Kind
  website, game, app        -> Craft Anything builds it (the folder holds intake and references)
  reel                      -> FFmpeg reel workflow (render.sh, check.sh, make-sample.sh)
  minecraft-paper           -> Paper plugin starter (Gradle wrapper, one /hello command)

.PARAMETER Name
  Folder name, e.g. "fernly-site".

.PARAMETER ProjectsDir
  Default: %USERPROFILE%\CraftProjects. A CLAUDE.md with the routing table is added there once.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('website', 'game', 'app', 'reel', 'minecraft-paper')][string]$Kind,
    [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9 ._-]*$')][string]$Name,
    [string]$ProjectsDir
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'CraftAnything.Common.ps1')

$repo = Get-CaRepo
$wf = Join-Path $repo 'fork\workflows'
if (-not $ProjectsDir) { $ProjectsDir = Join-Path $env:USERPROFILE 'CraftProjects' }
if (-not (Test-Path -LiteralPath $ProjectsDir)) { [void](New-Item -ItemType Directory -Path $ProjectsDir) }
$guide = Join-Path $ProjectsDir 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $guide)) {
    Copy-Item -LiteralPath (Join-Path $wf 'projects-CLAUDE.md') -Destination $guide
    Write-CaOk "Added $guide (routing for Claude Code sessions opened in this folder)"
}

$dest = Join-Path $ProjectsDir $Name
if (Test-Path -LiteralPath $dest) { Write-CaFail "$dest already exists; nothing changed."; exit 1 }

switch ($Kind) {
    'reel' { Copy-Item -LiteralPath (Join-Path $wf 'reel') -Destination $dest -Recurse }
    'minecraft-paper' { Copy-Item -LiteralPath (Join-Path $wf 'minecraft-paper') -Destination $dest -Recurse }
    default { [void](New-Item -ItemType Directory -Path $dest) }
}
foreach ($d in @('input', 'output')) {
    $p = Join-Path $dest $d
    if (-not (Test-Path -LiteralPath $p)) { [void](New-Item -ItemType Directory -Path $p) }
}
$intake = Get-Content -LiteralPath (Join-Path $wf 'INTAKE.md') -Raw
$intake = $intake.Replace('{{KIND}}', $Kind).Replace('{{NAME}}', $Name).Replace('{{DATE}}', (Get-Date).ToString('yyyy-MM-dd'))
Set-Content -LiteralPath (Join-Path $dest 'INTAKE.md') -Value $intake -Encoding UTF8
Set-Content -LiteralPath (Join-Path $dest 'STATUS.md') -Value @("# Status: $Name", '', '- [ ] Not started. Record verified results here with the exact commands.') -Encoding UTF8

Write-CaOk "Created $dest"
switch ($Kind) {
    'reel' { Write-CaNext "Put your recordings in $dest\input, then in Claude Code (opened in that folder): `"Use my recordings in input/ to make a 20-second vertical reel; follow README.md`"." }
    'minecraft-paper' { Write-CaNext "Fill in INTAKE.md (exact server version), then in Claude Code: `"Implement the feature in INTAKE.md in this Paper plugin; follow README.md`"." }
    default {
        $cli = & (Join-Path $PSScriptRoot 'Start-CraftAnything.ps1') -Cli 2>$null
        Write-CaNext "Put references in $dest\input, then use the app's Make screen, or: & `"$cli`" --format text rebuild - `"<your request>`" --project-folder `"$dest\build`""
    }
}
exit 0
