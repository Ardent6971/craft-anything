# Start on the Windows desktop

The short checklist. Everything here uses the scripts in [`fork/windows`](../../fork/windows);
what was tested and what still needs your PC is in [the report](REPORT.md).

## Checklist (about 15 minutes, plus downloads)

1. **Claude Code and Git.** If `claude --version` doesn't work in PowerShell, install Claude
   Code with the Windows steps at <https://code.claude.com/docs/en/setup> and Git for Windows
   (`winget install --id Git.Git -e`, or <https://git-scm.com/downloads/win>). Claude Code on
   Windows needs Git's bash. Open a **new** PowerShell window afterwards.

2. **Get this fork** (until the setup PR is merged, use its branch):

   ```powershell
   git clone --branch claude/craftanything-windows-setup-gehpkc https://github.com/Ardent6971/craft-anything "$HOME\craft-anything"
   cd "$HOME\craft-anything\fork\windows"
   ```

3. **Check** (read-only; ends with one "Next:" line):

   ```powershell
   .\check.cmd
   ```

   If it says to sign in: `claude auth login` (Anthropic's own sign-in in your browser), then
   run `.\check.cmd` again.

4. **Set up** (downloads the verified app, connects Claude Code, picks it as the builder):

   ```powershell
   .\setup.cmd
   ```

   It shows exactly what it will add to Claude Code's config and asks `y/N` first. Answer `y`.
   Restart any open Claude Code window afterwards.

5. **Start and make a first project:**

   ```powershell
   .\start.cmd
   ```

   In the app, ask: *"Make a small **website** in plain HTML and CSS for a fictional plant shop:
   a header with links to two sections, three product cards and one button that shows a short
   message. No framework."* Say **website**: "a page" alone is treated as a desktop app (found
   in the live test, see the report). When it says Ready, open it, make the window narrow and
   wide, and click the links and the button.

Then pick a route for real work: [workflows](WORKFLOWS.md), or make a folder with
`.\new-project.cmd -Kind reel -Name "my reel"` (kinds: website, game, app, reel, minecraft-paper).

## What setup installs, and where

| Thing | Where | Notes |
|---|---|---|
| Craft Anything 0.3.0 (GUI + CLI together) | `%LOCALAPPDATA%\CraftAnythingFork\portable-0.3.0-x64` | Upstream's published release; ZIP checked against the pinned SHA-256 **and** the publisher's `SHA256SUMS.txt` before extracting |
| Which build is current | `...\CraftAnythingFork\current.json` | `start.cmd` and `check.cmd` read it and print the version |
| Craft Anything settings | `%APPDATA%\craft-anything` | setup removes the release's `portable.txt` so both routes share settings (`-KeepPortableData` keeps it) |
| Claude Code connection | `%USERPROFILE%\.claude.json` (`mcpServers.craft-anything`) and `%USERPROFILE%\.claude\skills\craft-anything` | Written by Craft Anything's own `setup --client claude_code`; other entries are kept |
| Config backups | `...\CraftAnythingFork\backups\claude.json.<time>.bak`, plus `%USERPROFILE%\.claude.json.craft-anything.backup` (first setup only) | Stay on your PC |

`start.cmd` sets `WGPU_BACKEND=dx12` for the 0.3.0 app only (its own process): 0.3.0 can crash
at start on some Intel graphics drivers, fixed upstream after 0.3.0 the same way.

## Two routes

- **Portable (default)**: upstream release **0.3.0**, fast to install. It lacks three fixes
  this fork's source has (see the [audit](AUDIT.md)): the graphics start-up fix (covered by
  `start.cmd`), builders never resuming another builder's session, and passing Claude Code's task
  on stdin (0.3.0 passes it on the command line, so a very long brief, over 32,767 characters,
  fails on Windows). Fine for a first try and small projects.
- **Source**: builds this fork. Needs Rust 1.97+ (<https://rustup.rs>, accept the Visual Studio
  C++ build tools it offers) and ~10 GB free. Then `.\setup.cmd -Route Source`. The programs are
  copied to `...\CraftAnythingFork\source-<commit>`, so later rebuilds never fight a running copy.
  Switching routes re-points Claude Code at the new CLI.

## Undo

- Remove only the Claude Code connection (keeps everything else in the file as it is now):
  `& "$env:LOCALAPPDATA\CraftAnythingFork\portable-0.3.0-x64\craft-anything-cli.exe" uninstall`
  (setup prints the exact command for the build it installed).
- Put back the whole config file as it was before setup: close Claude Code, then
  `.\restore-claude-config.cmd` (lists the backups, saves the current file first, asks first).
- Remove the app: delete `%LOCALAPPDATA%\CraftAnythingFork` (and `%APPDATA%\craft-anything` for
  its settings).

## If something fails

Every script stops at the first problem and ends with one `Next:` line. Common ones:

| Message | Do this |
|---|---|
| `claude` not found | Install Claude Code (step 1); open a new window |
| Checksum mismatch | Nothing was run or kept. Run setup again; if it repeats, don't install |
| Could not replace / copy (in use) | Close Craft Anything and Claude Code, run setup again |
| No window after `start.cmd` | Look at `%APPDATA%\craft-anything\desktop.log`; try `$env:WGPU_BACKEND='vulkan'; .\start.cmd` |
| Scripts blocked by policy | The `.cmd` files run PowerShell with `-ExecutionPolicy Bypass` for that one process only; use them rather than the `.ps1` files |

Options: `.\setup.cmd -Yes` (no question), `-SkipClaude` (app only), `-InstallRoot <folder>`;
`.\check.cmd -Quick` skips the doctor's MCP handshake.
