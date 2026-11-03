<#
.SYNOPSIS
  Read-only check of this PC for Craft Anything with Claude Code. Changes nothing.

.DESCRIPTION
  Reports the base requirements (Windows, Claude Code, Git for Windows, sign-in), the installed
  Craft Anything (if setup ran), what the source route would need, and the optional tools for
  website, video, Minecraft and game projects. Ends with one next step.
  Exit code: 0 when the base requirements are met, 1 when something required is missing.

.PARAMETER InstallRoot
  Where setup keeps installs (default: %LOCALAPPDATA%\CraftAnythingFork).

.PARAMETER Quick
  Skip `craft-anything-cli doctor` (which starts the MCP server for a handshake).
#>
[CmdletBinding()]
param(
    [string]$InstallRoot,
    [switch]$Quick
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'CraftAnything.Common.ps1')

$required = New-Object System.Collections.ArrayList
$next = $null
function Set-Next([string]$Text) { if (-not $script:next) { $script:next = $Text } }

if (-not (Test-CaWindows)) {
    Write-CaFail 'This script is for Windows. On Linux or macOS follow docs/fork/WINDOWS-START.md by hand.'
    exit 1
}

$root = Get-CaRoot $InstallRoot
$repo = Get-CaRepo

# --- System ---------------------------------------------------------------------------------
Write-CaStep 'This PC'
$osName = ''
try { $osName = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption } catch { $osName = 'Windows' }
$arch = Get-CaArch
Write-CaInfo "$osName $([Environment]::OSVersion.Version), $arch"
Write-CaInfo "PowerShell $($PSVersionTable.PSVersion)"
if ($PSVersionTable.PSVersion -lt [version]'5.1') {
    Write-CaFail 'PowerShell 5.1 or newer is needed (Windows 10 and 11 include it).'
    [void]$required.Add('powershell')
}
if (-not $script:CaRelease.Assets.ContainsKey($arch)) {
    Write-CaWarn "No pinned Windows build for '$arch'; only the source route may work."
}
try {
    $drive = (Split-Path -Qualifier $root).TrimEnd(':')
    $free = (Get-PSDrive -Name $drive -ErrorAction Stop).Free
    $gb = [math]::Round($free / 1GB, 1)
    if ($gb -lt 2) { Write-CaWarn "$gb GB free on ${drive}: (the app needs ~0.3 GB; a source build ~10 GB)" }
    else { Write-CaOk "$gb GB free on ${drive}:" }
} catch { Write-CaInfo 'Free disk space: unknown' }
if ($env:HOME -and $env:USERPROFILE -and ($env:HOME.TrimEnd('\') -ne $env:USERPROFILE.TrimEnd('\'))) {
    Write-CaWarn "HOME is set to '$env:HOME' (not your profile folder). Craft Anything's setup writes Claude Code's config under HOME; Claude Code reads it under your profile. Clear HOME for these commands, or set CLAUDE_CONFIG_DIR."
}

# --- Claude Code (required) -----------------------------------------------------------------
Write-CaStep 'Claude Code (required)'
$claude = Find-CaClaude
if (-not $claude) {
    Write-CaFail 'Claude Code (the `claude` command) was not found. The Claude desktop or phone app is not the same program.'
    [void]$required.Add('claude')
    Set-Next 'Install Claude Code for Windows from https://code.claude.com/docs/en/setup, open a NEW PowerShell window, then run check.cmd again.'
} else {
    $v = Invoke-CaNative -File $claude -Arguments @('--version')
    if ($v.Code -eq 0) { Write-CaOk "$(($v.Lines | Select-Object -First 1)) at $claude" }
    else { Write-CaFail "Found $claude but it did not start (exit $($v.Code))."; [void]$required.Add('claude') ; Set-Next "Reinstall Claude Code; '$claude --version' failed." }
    if ($v.Code -eq 0) {
        $auth = Get-CaClaudeAuth $claude
        if ($auth.LoggedIn) { Write-CaOk "Signed in ($($auth.Method))" }
        else {
            Write-CaWarn 'Not signed in. Sign in with Claude Code''s own flow: claude auth login'
            Set-Next 'Run: claude auth login   (in a new PowerShell window; it opens Anthropic''s sign-in), then run check.cmd again.'
        }
    }
}
$git = Find-CaProgram 'git'
if ($git) {
    $gv = Invoke-CaNative -File $git -Arguments @('--version')
    Write-CaOk "$(($gv.Lines | Select-Object -First 1))"
    $bash = $env:CLAUDE_CODE_GIT_BASH_PATH
    if (-not $bash) {
        $gitRoot = Split-Path (Split-Path $git -Parent) -Parent
        $bash = Join-Path $gitRoot 'bin\bash.exe'
    }
    if (Test-Path -LiteralPath $bash) { Write-CaOk "Git Bash at $bash (Claude Code runs commands in it)" }
    else { Write-CaWarn "Git Bash not found next to git. Claude Code on Windows needs Git for Windows' bash.exe (or CLAUDE_CODE_GIT_BASH_PATH)." }
} else {
    Write-CaFail 'Git for Windows was not found. Claude Code on Windows needs it.'
    [void]$required.Add('git')
    Set-Next 'Install Git for Windows from https://git-scm.com/downloads/win (default options), open a new PowerShell window, then run check.cmd again.'
}

# --- Craft Anything -------------------------------------------------------------------------
Write-CaStep 'Craft Anything'
$cur = Read-CaCurrent $root
$installed = $null
if ($cur) {
    $dir = Get-CaProp $cur 'dir'
    $installed = $dir
    $ver = Get-CaAppVersion $dir
    if ($ver) {
        Write-CaOk "Installed by setup: $ver ($(Get-CaProp $cur 'route' '?') route$(if (Get-CaProp $cur 'commit') { ', commit ' + (Get-CaProp $cur 'commit') })) in $dir"
    } else {
        Write-CaFail "setup recorded $dir, but its CLI did not run."
        [void]$required.Add('app')
        Set-Next 'Run setup.cmd again.'
        $installed = $null
    }
} else {
    Write-CaInfo "Not installed by this fork's setup yet (looked in $root)."
    Set-Next 'Run setup.cmd (downloads the verified 0.3.0 portable app and connects it to Claude Code).'
}
$other = @(Get-Command 'craft-anything-cli' -CommandType Application -ErrorAction SilentlyContinue | ForEach-Object { $_.Source })
foreach ($o in $other) {
    if (-not $installed -or -not $o.StartsWith($installed, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-CaInfo "Another craft-anything-cli is on PATH: $o (setup registers the one it installed)."
    }
}
$cfg = Get-CaClaudeConfigPath
if (Test-Path -LiteralPath $cfg) {
    $entry = $null
    try {
        $j = Get-Content -LiteralPath $cfg -Raw | ConvertFrom-Json
        $entry = Get-CaProp (Get-CaProp $j 'mcpServers') 'craft-anything'
    } catch { Write-CaWarn "Could not read $cfg as JSON (setup will report the exact problem)." }
    if ($entry) {
        $cmd = Get-CaProp $entry 'command' ''
        if ($cmd -and (Test-Path -LiteralPath $cmd)) { Write-CaOk "Claude Code has a craft-anything MCP entry: $cmd" }
        else { Write-CaWarn "Claude Code's craft-anything entry points to a missing program: $cmd"; Set-Next 'Run setup.cmd again to point Claude Code at the installed CLI.' }
    } else {
        Write-CaInfo "Claude Code has no craft-anything entry in $cfg yet."
    }
} else {
    Write-CaInfo "No Claude Code user config yet ($cfg); it appears after Claude Code's first run."
}
if ($installed -and -not $Quick) {
    Write-CaInfo 'craft-anything-cli doctor --client claude_code (read-only; starts the MCP server once to talk to it):'
    $d = Invoke-CaNative -File (Join-Path $installed $script:CaCli) -Arguments @('doctor', '--client', 'claude_code') -Show
    if ($d.Code -ne 0) { Write-CaWarn 'doctor found problems (read the lines above; optional engines are only warnings).' }
}

# --- Source route (only for building the fork) ----------------------------------------------
Write-CaStep 'Source route (only for -Route Source)'
$min = Get-CaRustMinimum $repo
$cargoHome = $env:CARGO_HOME
if (-not $cargoHome) { $cargoHome = Join-Path $env:USERPROFILE '.cargo' }
$cargo = Find-CaProgram 'cargo' @((Join-Path $cargoHome 'bin\cargo.exe'))
if ($cargo) {
    $rv = Invoke-CaNative -File $cargo -Arguments @('--version')
    $line = ($rv.Lines | Select-Object -First 1)
    $num = ($line -replace '^cargo\s+', '')
    if ($min -and -not (Test-CaVersionAtLeast $num $min)) { Write-CaWarn "$line is older than this checkout's rust-version $min. Run: rustup update stable" }
    else { Write-CaOk "$line (needs $min or newer)" }
} else {
    Write-CaInfo "Rust not found (needs $min or newer from https://rustup.rs; not needed for the portable route)."
}
$msvc = Find-CaMsvc
if ($msvc) { Write-CaOk "Visual Studio C++ build tools: $msvc" }
else { Write-CaInfo 'Visual Studio C++ build tools not found (rustup offers them; not needed for the portable route).' }

# --- Optional workflow tools ------------------------------------------------------------------
Write-CaStep 'Optional project tools (install only for projects that need them)'
$browsers = @()
foreach ($pair in @(
        @(${env:ProgramFiles(x86)}, 'Microsoft\Edge\Application\msedge.exe'),
        @($env:ProgramFiles, 'Microsoft\Edge\Application\msedge.exe'),
        @($env:ProgramFiles, 'Google\Chrome\Application\chrome.exe'),
        @($env:LOCALAPPDATA, 'Google\Chrome\Application\chrome.exe'))) {
    if (-not $pair[0]) { continue }
    $b = Join-Path $pair[0] $pair[1]
    if (Test-Path -LiteralPath $b) { $browsers += $b }
}
if ($browsers.Count -gt 0) { Write-CaOk "Website: browser $($browsers[0])" } else { Write-CaWarn 'Website: no Edge or Chrome found (website checks and captures use one).' }
$node = Find-CaProgram 'node'
if ($node) { $nv = Invoke-CaNative -File $node -Arguments @('--version'); Write-CaOk "Website (framework stacks): Node $(($nv.Lines | Select-Object -First 1))" }
else { Write-CaInfo 'Website (framework stacks): Node.js not found. Plain HTML/CSS sites do not need it.' }
$ff = Find-CaProgram 'ffmpeg'
$fp = Find-CaProgram 'ffprobe'
if ($ff -and $fp) { Write-CaOk "Video: ffmpeg and ffprobe at $(Split-Path $ff -Parent)" } else { Write-CaInfo 'Video: ffmpeg/ffprobe not found (needed for the reel workflow only).' }
$java = Find-CaProgram 'java'
if ($java) {
    $jv = Invoke-CaNative -File $java -Arguments @('-version')
    $jl = @($jv.Lines | Where-Object { $_ -match 'version' }) | Select-Object -First 1
    Write-CaOk "Minecraft: $jl (the Minecraft version decides which JDK is right)"
} else { Write-CaInfo 'Minecraft: no Java found (a JDK matching the Minecraft version is needed for mods/plugins).' }
$godot = $null
foreach ($n in @('godot', 'godot4', 'Godot_v4')) { if (-not $godot) { $godot = Find-CaProgram $n } }
if ($godot) { Write-CaOk "Games: Godot at $godot" } else { Write-CaInfo 'Games: Godot not found. Name the engine you want in each game request; nothing is installed by default.' }

# --- Summary ----------------------------------------------------------------------------------
Write-CaStep 'Summary'
if ($required.Count -eq 0) {
    Write-CaOk 'Base requirements are met.'
} else {
    Write-CaFail "Missing: $($required -join ', ')"
}
if (-not $next) { $next = 'Run start.cmd to open Craft Anything. Pick a project route in docs/fork/WORKFLOWS.md.' }
Write-CaNext $next
if ($required.Count -eq 0) { exit 0 } else { exit 1 }
