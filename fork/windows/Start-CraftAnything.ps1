<#
.SYNOPSIS
  Open the Craft Anything build that setup installed, and say which one it is.

.PARAMETER InstallRoot
  Default: %LOCALAPPDATA%\CraftAnythingFork (or CRAFT_ANYTHING_FORK_ROOT).

.PARAMETER Cli
  Print the CLI's full path instead of opening the app (for commands such as `rebuild`).
#>
[CmdletBinding()]
param(
    [string]$InstallRoot,
    [switch]$Cli
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'CraftAnything.Common.ps1')

$root = Get-CaRoot $InstallRoot
$cur = Read-CaCurrent $root
if (-not $cur) {
    Write-CaFail "Craft Anything isn't installed by this fork's setup yet ($root)."
    Write-CaNext 'Run setup.cmd first.'
    exit 1
}
$dir = Get-CaProp $cur 'dir' ''
$gui = Join-Path $dir $script:CaGui
$cliPath = Join-Path $dir $script:CaCli
if (-not (Test-Path -LiteralPath $gui) -or -not (Test-Path -LiteralPath $cliPath)) {
    Write-CaFail "The recorded install is incomplete: $dir"
    Write-CaNext 'Run setup.cmd again.'
    exit 1
}
if ($Cli) { Write-Output $cliPath; exit 0 }

$route = Get-CaProp $cur 'route' '?'
$ver = Get-CaProp $cur 'version' ''
$commit = Get-CaProp $cur 'commit' ''
$label = "$ver ($route"
if ($commit) { $label += ", commit $commit" }
$label += ')'
Write-CaInfo "Starting $label from $dir"

# 0.3.0 starts Vulkan too, which crashed some Intel drivers before any window opened (upstream
# #394, fixed after 0.3.0 by starting DX12 only). Ask 0.3.0 for DX12 the same way, for this
# process only, unless the person chose a backend themselves.
if ($route -eq 'Portable' -and -not $env:WGPU_BACKEND) {
    $env:WGPU_BACKEND = 'dx12'
    Write-CaInfo 'WGPU_BACKEND=dx12 for this start (0.3.0 graphics workaround; unset by closing this window).'
}

Start-Process -FilePath $gui -WorkingDirectory $dir
Write-CaOk 'Opened. If no window appears, see the log folder named in docs/fork/WINDOWS-START.md.'
exit 0
