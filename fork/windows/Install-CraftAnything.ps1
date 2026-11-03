<#
.SYNOPSIS
  Install Craft Anything and connect it to your existing Claude Code. Safe to run again.

.DESCRIPTION
  1. Installs the app (GUI + CLI side by side) into a versioned folder under the install root:
     - Portable (default): the pinned upstream v0.3.0 portable ZIP, checked against the pinned
       SHA-256 and the publisher's SHA256SUMS.txt before anything is extracted or run.
     - Source: builds this checkout (`cargo build --release --locked`) and copies both programs
       to their own folder, so a later rebuild never fights a running copy.
  2. Records which build is current (current.json), for start.cmd and check.cmd.
  3. Connects Claude Code with Craft Anything's own `setup --client claude_code` (it merges into
     Claude Code's config and keeps a first-time backup); this script also copies the config to
     <install root>\backups first. Shows the preview and asks before writing unless -Yes.
  4. Adds Claude Code as Craft Anything's builder (`ai add` / `ai builder`), then runs `doctor`.
  Sign-in stays in Claude Code's own flow (`claude auth login`); no token is read or stored.

.PARAMETER Route
  Portable (default) or Source.

.PARAMETER InstallRoot
  Default: %LOCALAPPDATA%\CraftAnythingFork (or CRAFT_ANYTHING_FORK_ROOT).

.PARAMETER Yes
  Apply the Claude Code connection without asking (still shows the preview).

.PARAMETER SkipClaude
  Only install the app; leave Claude Code's config and the builder choice alone.

.PARAMETER KeepPortableData
  Portable route: keep portable.txt, so settings stay in the app folder instead of the normal
  per-user folder (%APPDATA%\craft-anything). Off by default, so both routes share settings.
#>
[CmdletBinding()]
param(
    [ValidateSet('Portable', 'Source')][string]$Route = 'Portable',
    [string]$InstallRoot,
    [switch]$Yes,
    [switch]$SkipClaude,
    [switch]$KeepPortableData
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'CraftAnything.Common.ps1')

function Stop-Ca([string]$Message, [string]$Next, [int]$Code = 1) {
    Write-CaFail $Message
    if ($Next) { Write-CaNext $Next }
    exit $Code
}

if (-not (Test-CaWindows)) { Stop-Ca 'This script is for Windows.' 'Follow docs/fork/WINDOWS-START.md by hand on other systems.' }
if ($PSVersionTable.PSVersion -lt [version]'5.1') { Stop-Ca 'PowerShell 5.1 or newer is needed.' 'Use Windows PowerShell 5.1 (built into Windows 10/11) or PowerShell 7.' }

$root = Get-CaRoot $InstallRoot
$repo = Get-CaRepo
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is very slow with a progress bar in 5.1
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }

Write-CaStep "Install root: $root"
foreach ($d in @($root, (Join-Path $root 'downloads'), (Join-Path $root 'backups'))) {
    if (-not (Test-Path -LiteralPath $d)) { [void](New-Item -ItemType Directory -Path $d) }
}

# --- 1. The app ---------------------------------------------------------------------------------

function Install-CaPortable {
    $arch = Get-CaArch
    if (-not $script:CaRelease.Assets.ContainsKey($arch)) { Stop-Ca "No pinned portable build for '$arch'." 'Use -Route Source.' }
    $asset = $script:CaRelease.Assets[$arch]
    $ver = $script:CaRelease.Version
    $folder = $asset.Name -replace '\.zip$', ''
    $dest = Join-Path $root "portable-$ver-$arch"
    $marker = Join-Path $dest '.verified-sha256'

    if ((Test-Path -LiteralPath $marker) -and ((Get-Content -LiteralPath $marker -Raw).Trim() -eq $asset.Sha256) -and
        (Test-Path -LiteralPath (Join-Path $dest $script:CaGui)) -and (Test-Path -LiteralPath (Join-Path $dest $script:CaCli))) {
        Write-CaOk "Already installed and verified: $dest"
        return @{ Dir = $dest; Version = $ver; Commit = ''; Source = "$($script:CaRelease.BaseUrl)/$($asset.Name)" }
    }

    $dl = Join-Path $root 'downloads'
    $zip = Join-Path $dl $asset.Name
    $sums = Join-Path $dl "SHA256SUMS-$ver.txt"
    Write-CaStep "Downloading Craft Anything $ver ($arch, portable)"
    if (-not (Test-Path -LiteralPath $zip) -or ((Get-CaSha256 $zip) -ne $asset.Sha256)) {
        $part = "$zip.part"
        if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
        try { Invoke-WebRequest -UseBasicParsing -Uri "$($script:CaRelease.BaseUrl)/$($asset.Name)" -OutFile $part }
        catch { Stop-Ca "Download failed: $($_.Exception.Message)" 'Check the internet connection and run setup.cmd again.' }
        Move-Item -LiteralPath $part -Destination $zip -Force
    }
    try { Invoke-WebRequest -UseBasicParsing -Uri "$($script:CaRelease.BaseUrl)/$($script:CaRelease.Sums)" -OutFile $sums }
    catch { Stop-Ca "Could not download the publisher's checksums: $($_.Exception.Message)" 'Run setup.cmd again when the release page is reachable.' }

    $have = Get-CaSha256 $zip
    $listed = $null
    foreach ($l in Get-Content -LiteralPath $sums) {
        $parts = $l -split '\s+', 2
        if ($parts.Count -eq 2 -and $parts[1].Trim().TrimStart('*') -eq $asset.Name) { $listed = $parts[0].ToLowerInvariant() }
    }
    if ($have -ne $asset.Sha256 -or $listed -ne $asset.Sha256) {
        Remove-Item -LiteralPath $zip -Force
        Stop-Ca "Checksum mismatch for $($asset.Name): file $have, pinned $($asset.Sha256), publisher list $listed. The file was deleted and nothing was run." 'Run setup.cmd again; if it repeats, do not install and report it.'
    }
    Write-CaOk "SHA-256 matches the pinned value and the publisher's SHA256SUMS.txt: $have"

    $stage = Join-Path $root "stage-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    try {
        Expand-Archive -LiteralPath $zip -DestinationPath $stage -Force
        $inner = Join-Path $stage $folder
        if (-not (Test-Path -LiteralPath (Join-Path $inner $script:CaCli))) { Stop-Ca "The archive does not contain $folder\$($script:CaCli)." 'Report this; nothing was installed.' }
        if (-not $KeepPortableData) {
            # Upstream's portable.txt says: delete it to use the normal per-user settings folder.
            $pt = Join-Path $inner 'portable.txt'
            if (Test-Path -LiteralPath $pt) { Remove-Item -LiteralPath $pt -Force }
        }
        if (Test-Path -LiteralPath $dest) {
            try { Remove-Item -LiteralPath $dest -Recurse -Force }
            catch { Stop-Ca "Could not replace $dest (is Craft Anything or Claude Code using it?)." 'Close Craft Anything and Claude Code, then run setup.cmd again.' }
        }
        Move-Item -LiteralPath $inner -Destination $dest
        Set-Content -LiteralPath $marker -Value $asset.Sha256 -Encoding ASCII
    } finally {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Write-CaOk "Installed to $dest"
    return @{ Dir = $dest; Version = $ver; Commit = ''; Source = "$($script:CaRelease.BaseUrl)/$($asset.Name)" }
}

function Install-CaSource {
    $min = Get-CaRustMinimum $repo
    $cargoHome = $env:CARGO_HOME
    if (-not $cargoHome) { $cargoHome = Join-Path $env:USERPROFILE '.cargo' }
    $cargo = Find-CaProgram 'cargo' @((Join-Path $cargoHome 'bin\cargo.exe'))
    if (-not $cargo) { Stop-Ca 'Rust (cargo) was not found.' "Install Rust $min or newer from https://rustup.rs (accept its Visual Studio C++ build tools offer), open a new PowerShell window, then run setup.cmd -Route Source again." }
    $rv = Invoke-CaNative -File $cargo -Arguments @('--version')
    $num = (($rv.Lines | Select-Object -First 1) -replace '^cargo\s+', '')
    if ($min -and -not (Test-CaVersionAtLeast $num $min)) { Stop-Ca "cargo $num is older than this checkout's rust-version $min." 'Run: rustup update stable   then run setup again.' }
    if (-not (Find-CaMsvc)) { Write-CaWarn 'Visual Studio C++ build tools were not found by vswhere; the build may fail at linking.' }

    $git = Find-CaProgram 'git'
    $commit = 'unknown'
    $dirty = ''
    if ($git) {
        $c = Invoke-CaNative -File $git -Arguments @('-C', $repo, 'rev-parse', '--short=12', 'HEAD')
        if ($c.Code -eq 0) { $commit = ($c.Lines | Select-Object -First 1).Trim() }
        $s = Invoke-CaNative -File $git -Arguments @('-C', $repo, 'status', '--porcelain', '--untracked-files=no')
        if ($s.Code -eq 0 -and @($s.Lines | Where-Object { $_ }).Count -gt 0) { $dirty = '-dirty' }
    }

    Write-CaStep "Building this checkout ($commit$dirty) with $num; the first build takes a while"
    Push-Location -LiteralPath $repo
    try {
        $old = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $cargo build --release --locked -p craft-anything -p craft-anything-cli | Out-Host
        $code = $LASTEXITCODE
        $ErrorActionPreference = $old
    } finally { Pop-Location }
    if ($code -ne 0) { Stop-Ca "cargo build failed (exit $code)." 'Read the first error above. Missing linker -> install the Visual Studio C++ build tools; then run setup again.' }

    $target = $env:CARGO_TARGET_DIR
    if (-not $target) { $target = Join-Path $repo 'target' }
    $built = Join-Path $target 'release'
    $dest = Join-Path $root "source-$commit$dirty"
    if (-not (Test-Path -LiteralPath $dest)) { [void](New-Item -ItemType Directory -Path $dest) }
    foreach ($exe in @($script:CaGui, $script:CaCli)) {
        $from = Join-Path $built $exe
        if (-not (Test-Path -LiteralPath $from)) { Stop-Ca "The build did not produce $from." 'Check CARGO_TARGET_DIR and run setup again.' }
        $to = Join-Path $dest $exe
        if ((Test-Path -LiteralPath $to) -and ((Get-CaSha256 $to) -eq (Get-CaSha256 $from))) { continue }
        try { Copy-Item -LiteralPath $from -Destination $to -Force }
        catch { Stop-Ca "Could not copy $exe into $dest (is it running?)." 'Close Craft Anything and Claude Code, then run setup again.' }
    }
    $info = @("commit=$commit$dirty", "built=$((Get-Date).ToString('s'))", "cargo=$num", "repo=$repo")
    Set-Content -LiteralPath (Join-Path $dest 'BUILD.txt') -Value $info -Encoding ASCII
    Write-CaOk "Installed the fork build to $dest"
    return @{ Dir = $dest; Version = ''; Commit = "$commit$dirty"; Source = $repo }
}

if ($Route -eq 'Portable') { $app = Install-CaPortable } else { $app = Install-CaSource }
$cli = Join-Path $app.Dir $script:CaCli
$ver = Get-CaAppVersion $app.Dir
if (-not $ver) { Stop-Ca "$cli did not start." 'Run check.cmd to see what is missing, then setup.cmd again.' }
Write-CaOk "Running: $ver"

Write-CaCurrent $root @{
    route       = $Route
    dir         = $app.Dir
    version     = $ver
    commit      = $app.Commit
    source      = $app.Source
    installedAt = (Get-Date).ToString('s')
}

if ($SkipClaude) {
    Write-CaNext "Run start.cmd. (Claude Code was not connected: -SkipClaude.)"
    exit 0
}

# --- 2. Claude Code -------------------------------------------------------------------------------

Write-CaStep 'Claude Code'
$claude = Find-CaClaude
if (-not $claude) {
    Stop-Ca 'Claude Code (the `claude` command) was not found, so it was not connected. The app itself is installed.' 'Install Claude Code from https://code.claude.com/docs/en/setup, open a new PowerShell window, and run setup.cmd again.' 2
}
$v = Invoke-CaNative -File $claude -Arguments @('--version')
Write-CaOk "$(($v.Lines | Select-Object -First 1)) at $claude"
$auth = Get-CaClaudeAuth $claude
if ($auth.LoggedIn) { Write-CaOk 'Signed in.' } else { Write-CaWarn 'Not signed in yet; connecting anyway. Builds need: claude auth login' }

# Our own dated copy of Claude Code's config, besides the one setup keeps.
$cfg = Get-CaClaudeConfigPath
if (Test-Path -LiteralPath $cfg) {
    $bak = Join-Path (Join-Path $root 'backups') ("claude.json.{0}.bak" -f (Get-Date).ToString('yyyyMMdd-HHmmss'))
    Copy-Item -LiteralPath $cfg -Destination $bak
    Write-CaOk "Backed up $cfg to $bak"
}

Write-CaStep 'Preview: what setup would change'
$p = Invoke-CaNative -File $cli -Arguments @('--format', 'text', 'setup', '--client', 'claude_code', '--dry-run') -Show
if ($p.Code -ne 0) { Stop-Ca 'setup could not plan the change (see above).' 'Fix what it names (often an unreadable config file), then run setup.cmd again.' }
# Decide from the typed plan, not the wording: any config or skill file to create or update?
$pj = Invoke-CaNative -File $cli -Arguments @('--format', 'json', 'setup', '--client', 'claude_code', '--dry-run')
$changes = 1
try {
    $plan = Get-CaProp (($pj.Lines -join "`n") | ConvertFrom-Json) 'plan'
    $changes = @(@(Get-CaProp $plan 'actions' @()) | Where-Object { @('create', 'update') -contains (Get-CaProp $_ 'action') }).Count
    foreach ($s in @(Get-CaProp $plan 'skills' @())) {
        $changes += @(@(Get-CaProp $s 'files' @()) | Where-Object { @('create', 'update') -contains (Get-CaProp $_ 'action') }).Count
    }
} catch { $changes = 1 }
if ($changes -eq 0) {
    Write-CaOk 'Claude Code is already connected to this build.'
} else {
    if (-not $Yes) {
        $answer = Read-Host 'Apply these changes to Claude Code''s config? [y/N]'
        if ($answer -notmatch '^(y|yes)$') { Stop-Ca 'Not applied.' 'Run setup.cmd again and answer y, or run it with -Yes.' }
    }
    $a = Invoke-CaNative -File $cli -Arguments @('--format', 'text', 'setup', '--client', 'claude_code', '--yes') -Show
    if ($a.Code -ne 0) { Stop-Ca 'setup did not finish (see above).' 'Follow the remediation it printed, then run setup.cmd again.' }
    Write-CaOk 'Connected. Restart any open Claude Code session to load Craft Anything.'
}

# --- 3. Builder ---------------------------------------------------------------------------------------

Write-CaStep 'Builder: Claude Code'
$builderName = $null
$list = Invoke-CaNative -File $cli -Arguments @('--format', 'json', 'ai', 'list')
try {
    # Assign first: Windows PowerShell 5.1 passes a parsed JSON array down the pipeline as one object.
    $backends = ($list.Lines -join "`n") | ConvertFrom-Json
    foreach ($b in $backends) {
        if ((Get-CaProp $b 'kind') -eq 'agent_cli' -and (Get-CaProp $b 'name' '') -match 'Claude Code') { $builderName = Get-CaProp $b 'name' }
    }
} catch { }
if ($builderName) {
    Write-CaOk "Craft Anything already has '$builderName'."
} else {
    $add = Invoke-CaNative -File $cli -Arguments @('--format', 'text', 'ai', 'add', 'Claude Code', '--kind', 'agent_cli') -Show
    if ($add.Code -ne 0) { Write-CaWarn 'Could not add Claude Code as an AI (see above); trying to select it anyway.' }
    $builderName = 'Claude Code'
}
$bres = Invoke-CaNative -File $cli -Arguments @('--format', 'text', 'ai', 'builder', $builderName) -Show
if ($bres.Code -eq 0) { Write-CaOk "Builder: $builderName" } else { Write-CaWarn 'Could not select the builder; choose it in the app: Settings > AI.' }

# --- 4. Doctor ---------------------------------------------------------------------------------------

Write-CaStep 'Doctor'
$d = Invoke-CaNative -File $cli -Arguments @('--format', 'text', 'doctor', '--client', 'claude_code') -Show
$problems = $d.Code -ne 0

Write-CaStep 'Done'
Write-CaInfo "App: $ver ($Route) in $($app.Dir)"
Write-CaInfo "Undo the Claude Code connection: `"$cli`" uninstall   (or restore-claude-config.cmd)"
if (-not $auth.LoggedIn) { Write-CaNext 'Run: claude auth login   then start.cmd.'; exit 0 }
if ($problems) { Write-CaNext 'Read the doctor lines marked FAIL above (warnings about optional engines can wait), then run check.cmd.'; exit 1 }
Write-CaNext 'Run start.cmd, then try the first project in docs/fork/WINDOWS-START.md.'
exit 0
