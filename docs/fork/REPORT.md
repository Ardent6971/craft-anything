# Verification report: Windows setup PR

Date 2026-11-03. Base: fork `main` at `2e4afc5` plus PR #1's docs (`40d29d1`) plus this PR.
Where: a Linux cloud container (Ubuntu 24.04, x86_64), **not** the owner's PC. No Windows machine
was available, so every Windows row below is **not run** unless it says otherwise.

Versions: Rust/cargo 1.97.0, Claude Code 2.1.317 (signed in), FFmpeg 6.1.1, OpenJDK 21.0.12,
Gradle 8.14.3, Node 22.23.4, Chrome (Playwright's Chromium 1243 for checks).

## What ran, and the result

All runs used disposable folders: `HOME`, `CLAUDE_CONFIG_DIR` and `CRAFT_ANYTHING_CONFIG_DIR`
pointed at temp folders **with spaces in their names**. No real config was read or written.

| Check | Command (fork build, `target/debug/craft-anything-cli`) | Result |
|---|---|---|
| Build | `cargo build --locked -p craft-anything-cli` | passed |
| Format, secrets | `cargo fmt --all --check`, `cargo xtask secrets` | passed (no Rust code changed in this PR) |
| Release download | v0.3.0 `SHA256SUMS.txt` + Windows x64 portable ZIP, `sha256sum -c` | **OK**, `cf60e403…6d8`; ZIP holds GUI + CLI side by side. Not executed |
| Setup preview | `setup --client claude_code --dry-run` (an unrelated `other-server` entry present) | plan: update `.claude.json`, add skill; nothing written |
| Setup apply | `setup --client claude_code --yes` | `configured`; `other-server` kept; `.claude.json.craft-anything.backup` created |
| Setup rerun | same again | `unchanged`, `already_current` for config and skill |
| Builder | `ai add "Claude Code" --kind agent_cli`, `ai builder "Claude Code"` | added, selected (`[ai.roles] builder = "Claude Code"`) |
| Doctor | `doctor --client claude_code` | `healthy`: registration ok, skill current, MCP self-test (29 tools), Claude Code answered |
| Claude Code sees the server | `claude mcp list` with the temp `CLAUDE_CONFIG_DIR`, **not signed in** | `craft-anything … ✓ Connected` |
| All tools mount (upstream #490) | `claude -p … --mcp-config <temp> --strict-mcp-config`, init event | default server: 29/29; `mcp --deep --all-tools`: **315/315** (server lists 315) |
| Website, live | `rebuild - "Make a small website in plain HTML and CSS for a fictional plant shop…" --rounds 1 --unattended --backend "Claude Code"` | **Ready** in 82 s, "all 1 checks pass" (static site, nothing to build) |
| Website, checked by hand | Playwright at 390×844, 820×1180, 1440×900 | no horizontal overflow; both nav links scroll to their sections; button shows/hides the message (`details` open false→true→false); 0 script errors |
| Wording pitfall, live | same but "Make a plain HTML and CSS **page** …" | classified as an **app**: check "1 of 2 pass", builder wrote a launcher script and a headless-browser screenshot it started hung; see below |
| Reel pack | `make-sample.sh`; `render.sh --preview`; `render.sh` with captions; with `MUSIC` | 540×960 preview and 1080×1920 30 fps H.264/AAC/yuv420p; captions visible in extracted frames; silent clip got silence; missing clip → exit 2 |
| Paper plugin pack | `gradle build` on a copy of `fork/workflows/minecraft-paper` | `hello-plugin-0.1.0.jar` (Java 21 class files, filled-in `plugin.yml`), Paper API 1.21.11-R0.1-SNAPSHOT |
| Gradle wrapper | `sha256sum gradle-wrapper.jar` vs Gradle's published value | match `7d3a4ac4…172`; distribution SHA-256 pinned in the properties |
| PowerShell scripts (here) | — | not run in this container (no PowerShell). Checked: ASCII only, `.cmd` files CRLF |

## Windows run (GitHub Actions `windows-latest`, Windows PowerShell 5.1)

Workflow `fork-windows-setup.yml`, run 41678610946 on commit `5694445`. Install root, Claude
Code config and Craft Anything settings were disposable folders with spaces in their names.
Claude Code 2.1.317 from npm, **not signed in**.

| Step | Result |
|---|---|
| Parse all `.ps1` with 5.1, ASCII check | passed |
| `check.cmd -Quick` | ran; "Base requirements are met", next step `claude auth login` (correct: not signed in) |
| `setup.cmd -Yes` | downloaded the x64 ZIP, **SHA-256 matched pinned value and SHA256SUMS.txt**, installed, `0.3.0` ran; dated backup; preview then `configured`; builder added and selected; doctor `healthy` (registration, skill, MCP self-test 29 tools) |
| Config afterwards | `craft-anything` entry points at the installed CLI; unrelated `other-server` kept; `current.json` written |
| `claude mcp list` (Claude Code itself) | `craft-anything: …\craft-anything-cli.exe mcp - √ Connected` |
| `setup.cmd -Yes` again | "Already installed and verified", "Claude Code is already connected", builder kept: nothing changed |
| `start.cmd` | **the 0.3.0 app was running 20 s later with a window titled "Craft Anything"** (`WGPU_BACKEND=dx12`) |
| Restore | the script restored the chosen backup; the job's own assertion compared against the wrong file (Claude Code rewrites `.claude.json` on its first run) and failed. Assertion fixed in the next commit; see that run for restore, uninstall and the templates |

### Two findings from the live runs

1. **Say "website".** "Make a plain HTML and CSS **page** …" picked the *Plain HTML and CSS* stack
   but the **app** kind (the website kind listens for "website", "web page", "landing page",
   " site "). The app check wanted a runnable program ("1 of 2 checks pass"), so the builder wrote
   a shell launcher with a `--screenshot` mode; the headless browser that script started never
   exited, and the run sat on that command for 13 minutes. The same request saying "website" was
   Ready in 82 s. The old first-project wording in `WINDOWS-START.md` said "page"; it now says
   "website". A product fix (a web stack implying the website kind) is a pending follow-up.
2. **Stopping a run left the builder's command running.** Ctrl-C (SIGINT) stopped
   `craft-anything-cli rebuild` and Claude Code within 2 s, but the shell command Claude Code was
   running (bash → the launcher → headless Chrome) stayed, reparented to init: Claude Code starts
   tool commands in their own session (`setsid`), outside the process group the CLI kills. Cleaned
   up by hand. On Windows the CLI uses a Job Object, which may catch them: check after stopping a
   build there (Task Manager: no stray `chrome`/`bash`). Pending follow-up.

## Not run (needs Windows or the owner)

| Item | How to check | Where it is automated |
|---|---|---|
| The scripts on **your** PC (Windows 10/11 desktop, your real profile, signed in) | the checklist in `WINDOWS-START.md` | CI covered a Windows Server runner only (above) |
| `restore-claude-config.cmd`, `uninstall`, `new-project.cmd` on Windows | the checklist | CI workflow (second run) |
| Claude Code sign-in on the PC | `claude auth login`, `claude auth status` | owner only |
| A live build on Windows (Claude Code's bash is Git Bash there) | step 5 of the checklist | owner only (needs sign-in) |
| Source route on Windows (`-Route Source`, MSVC linker) | `setup.cmd -Route Source` | workflow, manual dispatch |
| Reel scripts in Git Bash on Windows (path conversion, libass in the FFmpeg build) | `new-project.cmd -Kind reel`, then the README | workflow |
| Paper plugin on a real server, `/hello` in game | the template README, step 4 | owner only (server JAR, EULA) |
| Fabric/NeoForge, resource/data packs | — | no template yet |
| Godot game build | `--build-with godot` | owner (install Godot first) |
| Local inference (F5) | `LOCAL-AI.md` | not started |

## Rollback

- Claude Code connection only: `craft-anything-cli.exe uninstall` (the path setup printed).
- Whole Claude Code config as before: `restore-claude-config.cmd` (backups in
  `%LOCALAPPDATA%\CraftAnythingFork\backups`, plus `.claude.json.craft-anything.backup`).
- App: delete `%LOCALAPPDATA%\CraftAnythingFork` and, for settings, `%APPDATA%\craft-anything`.
- This PR: revert it; it adds files under `fork/`, docs and one CI workflow, and changes no Rust code.
