# Shared helpers for this fork's Windows scripts. Dot-source it; it changes nothing by itself.
# Works in Windows PowerShell 5.1 and PowerShell 7. Keep this file ASCII: PowerShell 5.1 reads a
# script without a byte-order mark in the system code page.

Set-StrictMode -Version 2.0

# The pinned upstream release used by the portable route. Hashes are the publisher's
# SHA256SUMS.txt for v0.3.0 (checked against the downloaded file as well as this table).
$script:CaRelease = @{
    Version = '0.3.0'
    BaseUrl = 'https://github.com/storytold/craft-anything/releases/download/v0.3.0'
    Sums    = 'SHA256SUMS.txt'
    Assets  = @{
        x64   = @{ Name = 'craft-anything-0.3.0-windows-x64-portable.zip';   Sha256 = 'cf60e403c7eb33d51b8dd167335e79d031e516c39cac4a58c97fa70ef81ed6d8' }
        arm64 = @{ Name = 'craft-anything-0.3.0-windows-arm64-portable.zip'; Sha256 = '8fecfcbd58da897f8e08f86577351bcdba7906bbc1d69d7c35ec11c90cc08d30' }
        x86   = @{ Name = 'craft-anything-0.3.0-windows-x86-portable.zip';   Sha256 = 'f3fad6220fc9cac3e59b74d65cb648b607ed551e2b94128eefb62e160d092052' }
    }
}

$script:CaGui = 'craft-anything.exe'
$script:CaCli = 'craft-anything-cli.exe'

function Write-CaStep([string]$Text) { Write-Host ''; Write-Host "== $Text" -ForegroundColor Cyan }
function Write-CaOk([string]$Text) { Write-Host "  [ok]   $Text" -ForegroundColor Green }
function Write-CaInfo([string]$Text) { Write-Host "  [info] $Text" }
function Write-CaWarn([string]$Text) { Write-Host "  [warn] $Text" -ForegroundColor Yellow }
function Write-CaFail([string]$Text) { Write-Host "  [FAIL] $Text" -ForegroundColor Red }
function Write-CaNext([string]$Text) { Write-Host ''; Write-Host "Next: $Text" -ForegroundColor Cyan }

function Test-CaWindows {
    return ($env:OS -eq 'Windows_NT')
}

# Where installs, downloads, backups and the "current" marker live. Never inside the repository.
function Get-CaRoot([string]$Override) {
    if ($Override) { return [System.IO.Path]::GetFullPath($Override) }
    if ($env:CRAFT_ANYTHING_FORK_ROOT) { return [System.IO.Path]::GetFullPath($env:CRAFT_ANYTHING_FORK_ROOT) }
    if ($env:LOCALAPPDATA) { return (Join-Path $env:LOCALAPPDATA 'CraftAnythingFork') }
    return (Join-Path $HOME '.craft-anything-fork')
}

# The repository this script came from (fork/windows/ is two levels below it).
function Get-CaRepo {
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
}

# x64, arm64 or x86 for the operating system (not for this PowerShell process, which may be
# emulated on ARM).
function Get-CaArch {
    try {
        $a = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        switch ($a) { 'X64' { return 'x64' } 'Arm64' { return 'arm64' } 'X86' { return 'x86' } }
    } catch { }
    $raw = $env:PROCESSOR_ARCHITEW6432
    if (-not $raw) { $raw = $env:PROCESSOR_ARCHITECTURE }
    switch ($raw) { 'AMD64' { return 'x64' } 'ARM64' { return 'arm64' } 'x86' { return 'x86' } }
    return 'unknown'
}

# Run a program and return @{ Code; Lines }. Never throws for a non-zero exit or for text on
# stderr (Windows PowerShell 5.1 turns stderr into errors under ErrorActionPreference=Stop).
function Invoke-CaNative {
    param([Parameter(Mandatory = $true)][string]$File, [string[]]$Arguments = @(), [switch]$Show)
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $lines = @()
    $code = 1
    try {
        $out = & $File @Arguments 2>&1
        $code = $LASTEXITCODE
        foreach ($o in @($out)) {
            $line = "$o"
            $lines += $line
            if ($Show) { Write-Host "    $line" }
        }
    } catch {
        $lines += $_.Exception.Message
        if ($Show) { Write-Host "    $($_.Exception.Message)" }
        $code = 9009
    } finally {
        $ErrorActionPreference = $old
    }
    if ($null -eq $code) { $code = 0 }
    return @{ Code = [int]$code; Lines = $lines }
}

# The first program by this name that Windows would start, or $null.
function Find-CaProgram([string]$Name, [string[]]$Extra = @()) {
    $c = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { return $c.Source }
    foreach ($p in $Extra) { if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) { return $p } }
    return $null
}

function Find-CaClaude {
    $extra = @()
    if ($env:USERPROFILE) {
        $extra += (Join-Path $env:USERPROFILE '.local\bin\claude.exe')
        $extra += (Join-Path $env:USERPROFILE '.claude\local\claude.exe')
    }
    return (Find-CaProgram 'claude' $extra)
}

# Claude Code's sign-in state, read from `claude auth status`. Only loggedIn and the method are
# kept; nothing else from the output (it can name the account) is printed or stored.
function Get-CaClaudeAuth([string]$Claude) {
    $r = Invoke-CaNative -File $Claude -Arguments @('auth', 'status')
    $state = @{ LoggedIn = $false; Method = ''; Known = $false }
    $text = ($r.Lines -join "`n")
    try {
        $j = $text | ConvertFrom-Json
        $li = Get-CaProp $j 'loggedIn'
        if ($null -eq $li) { throw 'no loggedIn field' }
        $state.Known = $true
        $state.LoggedIn = [bool]$li
        $state.Method = "$(Get-CaProp $j 'authMethod' '')"
    } catch {
        $state.Known = $true
        $state.LoggedIn = ($r.Code -eq 0)
    }
    return $state
}

# The home folder Craft Anything's setup uses for Claude Code's config: HOME first, then
# USERPROFILE (crates/setup/src/clients.rs, Host::current).
function Get-CaSetupHome {
    if ($env:HOME) { return $env:HOME }
    return $env:USERPROFILE
}

function Get-CaClaudeConfigPath {
    if ($env:CLAUDE_CONFIG_DIR) { return (Join-Path $env:CLAUDE_CONFIG_DIR '.claude.json') }
    return (Join-Path (Get-CaSetupHome) '.claude.json')
}

function Get-CaCurrentPath([string]$Root) { return (Join-Path $Root 'current.json') }

function Read-CaCurrent([string]$Root) {
    $p = Get-CaCurrentPath $Root
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return $null }
    try { return (Get-Content -LiteralPath $p -Raw | ConvertFrom-Json) } catch { return $null }
}

# A property of a parsed JSON object, or $Default when it's missing (strict mode refuses a
# missing property).
function Get-CaProp($Object, [string]$Name, $Default = $null) {
    if ($null -eq $Object) { return $Default }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $Default }
    return $p.Value
}

function Write-CaCurrent([string]$Root, [hashtable]$Data) {
    $p = Get-CaCurrentPath $Root
    $tmp = "$p.tmp"
    ($Data | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $p -Force
}

function Get-CaSha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

# Version string from Cargo.toml's [workspace.package] rust-version, e.g. "1.97".
function Get-CaRustMinimum([string]$Repo) {
    $toml = Join-Path $Repo 'Cargo.toml'
    if (-not (Test-Path -LiteralPath $toml)) { return $null }
    foreach ($l in Get-Content -LiteralPath $toml) {
        if ($l -match '^\s*rust-version\s*=\s*"([0-9.]+)"') { return $Matches[1] }
    }
    return $null
}

function Test-CaVersionAtLeast([string]$Have, [string]$Need) {
    try {
        $h = [version]($Have -replace '^([0-9]+\.[0-9]+(\.[0-9]+)?).*$', '$1')
        $n = [version]$Need
        return ($h -ge $n)
    } catch { return $false }
}

# Visual Studio C++ build tools, found through vswhere (installed with every VS 2017+ setup).
function Find-CaMsvc {
    $pf = ${env:ProgramFiles(x86)}
    if (-not $pf) { $pf = $env:ProgramFiles }
    if (-not $pf) { return $null }
    $vswhere = Join-Path $pf 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $vswhere)) { return $null }
    $r = Invoke-CaNative -File $vswhere -Arguments @('-latest', '-products', '*', '-requires', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', '-property', 'installationPath')
    $path = @($r.Lines | Where-Object { $_ -and (Test-Path -LiteralPath $_) }) | Select-Object -First 1
    return $path
}

# Read the installed app folder's version as the CLI reports it ("craft-anything-cli 0.3.0").
function Get-CaAppVersion([string]$Dir) {
    $cli = Join-Path $Dir $script:CaCli
    if (-not (Test-Path -LiteralPath $cli)) { return $null }
    $r = Invoke-CaNative -File $cli -Arguments @('--version')
    if ($r.Code -ne 0) { return $null }
    return (($r.Lines | Select-Object -First 1) -replace '^\s+|\s+$', '')
}
