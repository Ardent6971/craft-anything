# Fork setup audit

Snapshot: 2026-11-03. This is a source and GitHub metadata review, not a Windows install test.

## Versions examined

| Item | Observed value |
|---|---|
| Fork | `Ardent6971/craft-anything`, public, default branch `main` |
| Fork source baseline | `2e4afc535cebb6ee556c5ea3f6b4e454487853f9` |
| Upstream | `storytold/craft-anything` |
| Upstream head observed | `ad5cd81b6a2ce5238024dadc9397ea0fc20170e5` |
| Comparison at review | Upstream 64 commits ahead, fork has no divergent commits at this baseline |
| Latest upstream release observed | `v0.3.0`, published 2026-11-02 |
| Workspace manifest | Version 0.3.0; Rust minimum 1.97; edition 2024 |

The release, the fork baseline and upstream main are distinct code versions even though
their manifest version can be the same. Recheck before updating; do not merge 64 commits
blindly or assume the prebuilt release includes the fork's later fixes.

## F1 re-check and baseline choice (2026-11-03, setup PR)

Re-read from git (not the GitHub API, which this environment can't reach for upstream):

| Item | Observed value |
|---|---|
| Fork `main` | still `2e4afc5`; this PR adds only docs, `fork/` and one CI workflow on top |
| Upstream `main` | `75bf5a3`, now **77** commits ahead of the fork; a test merge (`git merge-tree`) has no conflicts |
| Release `v0.3.0` | tag `e6280b5`, an ancestor of the fork baseline; still the newest release (`v0.4.0` assets return 404; upstream `main` already says 0.4.0) |
| `SHA256SUMS.txt` (v0.3.0) | downloaded; Windows x64 portable `cf60e403…6d8` (matches above), arm64 `8fecfcbd…9d7`, x86 `f3fad622…052` |
| Windows x64 portable ZIP | downloaded and hashed here: matches. Contains `craft-anything.exe` and `craft-anything-cli.exe` side by side, `portable.txt`, licences. Not executed (no Windows here) |

**What 0.3.0 lacks that the fork baseline has** (upstream's own R5.1 list): `0748ef1` (#414,
Windows starts DX12 only: the "it won't open" crash on some Intel drivers), `1e8f661` (#471, a
builder never continues another builder's session) and `3357daf` (#430, Claude Code's task on
stdin; 0.3.0 puts it on the command line, which fails past Windows' 32,767-character limit).

**What the fork baseline lacks that upstream `main` has**, relevant to this setup: `2920a7c`
(#637, restrict Claude Code's tools and ask before unknown ones), `6d90c65` (#558, Windows' own
shader compiler; how to start without the graphics card), `78e1f7d` (#583, "found but can't
start" message), `aeb86a6` (#653, agent setup/streaming fixes), `549ae5e` (#490, one MCP schema).
Upstream recorded #490 as not reproduced with 0.3.0 on Windows (314 of 315 tools mounted, the
315th being the approval tool); here the fork build mounted **315 of 315** in Claude Code 2.1.317
on Linux.

**Recommendation.** First run: the pinned **0.3.0 portable** release (fast, checksummed),
started with `WGPU_BACKEND=dx12` to cover #414. Ongoing use and any fork changes: the **fork
source build** (`setup.cmd -Route Source`), which has #414/#471/#430. Sync upstream in a
**separate PR** (it is conflict-free today, 179 files) and run the full checks there; it is not
bundled with the setup scripts.

## Windows prerequisites

| Need | For | Source | Notes |
|---|---|---|---|
| Windows 10/11, x64 (arm64/x86 builds also pinned) | everything | — | `check.cmd` reports OS and architecture |
| Windows PowerShell 5.1 | the scripts | built in | PowerShell 7 also works; scripts are ASCII for 5.1 |
| Claude Code (`claude`) | building, MCP | <https://code.claude.com/docs/en/setup> | sign in with `claude auth login` |
| Git for Windows | Claude Code's bash; cloning | <https://git-scm.com/downloads/win> or `winget install --id Git.Git -e` | |
| Edge or Chrome | website checks/captures | usually present | |
| Rust ≥ 1.97 + VS C++ build tools | source route only | <https://rustup.rs> | not lowered; the manifest's `rust-version` is read by the scripts |
| FFmpeg | reel workflow only | e.g. `winget install Gyan.FFmpeg` | |
| JDK matching the Minecraft version | Minecraft workflow only | e.g. Temurin 21 for 1.21.x | Paper's 26.x API needs Java 25 |
| Godot (or Rust) | small games only | <https://godotengine.org> | name the engine; Unity is the default otherwise |

Versions of Claude Code, Git, FFmpeg and JDKs are whatever is current when installed; the
scripts check presence and (for Rust) the minimum, and print what they find.

## What the source supports

| Area | Evidence in this fork | Setup consequence |
|---|---|---|
| Local desktop app | Rust workspace; egui UI, CLI, MCP server | Can run locally; needs a successful Windows launch check |
| Claude builder | `docs/claude-code.md`; `crates/ai/src/cli_agents/`; builder preflights | Needs the local `claude` executable, sign-in and a working `craft-anything-cli` |
| Agent registration | `apps/craft-anything-cli/src/setup_cmd.rs`; `crates/setup/src/clients.rs` | `setup --client claude_code --dry-run` previews changes; normal setup applies them |
| Diagnostics | `crates/setup/src/doctor.rs` | Doctor checks CLI, MCP handshake, registrations and optional engines; not full project quality |
| Target kinds | `crates/ai/src/rebuild/kinds/` | Built-in website, app and game routes; no dedicated video or Minecraft-mod route found |
| Stack recipes | `crates/ai/src/rebuild/stacks.toml` | Web stacks, Rust, Unity, Unreal, Godot; no dedicated FFmpeg/Remotion/Fabric recipe found |
| Local model APIs | `crates/ai/src/config.rs`, `lib.rs`, `openai.rs`, `detect.rs` | OpenAI-compatible endpoints are supported; choose a real served model id |
| API/local builder loop | `crates/engine/src/tools/build_tools.rs`; `docs/STATUS.md` limitations | File and command tools exist; status explicitly says no live API build verified yet |
| Extensions | `docs/extending.md` | MCP plugins, target-kind/check traits and typed stack tables are existing seams |
| Game checks | `docs/STATUS.md` | Includes a generated self-test; this is not independent proof of complete gameplay |
| Media editing | Searches of target kinds, stacks, tool docs and engine tools | No dedicated timeline-editing/video-export workflow found; needs external tooling or an extension |
| Minecraft mods | Same source search | General Java/game inspection does not establish mod-loader compatibility or mod packaging |

## Ready-made Windows option

The upstream release API lists these real assets (not just planned README filenames):

- [Portable x64 ZIP](https://github.com/storytold/craft-anything/releases/download/v0.3.0/craft-anything-0.3.0-windows-x64-portable.zip)
- [x64 MSI](https://github.com/storytold/craft-anything/releases/download/v0.3.0/craft-anything-0.3.0-windows-x64.msi)
- [Checksums](https://github.com/storytold/craft-anything/releases/download/v0.3.0/SHA256SUMS.txt)

The portable ZIP's API-reported SHA-256 is
`cf60e403c7eb33d51b8dd167335e79d031e516c39cac4a58c97fa70ef81ed6d8`.
This records release metadata; the ZIP was not downloaded, hashed or executed in this audit.
`packaging/windows/package.ps1` stages the GUI and CLI together and a portable settings marker.

## Gaps Claude must address

1. Choose a tested application baseline: pinned portable release for the fastest trial,
   or the fork source for later fixes/custom changes. Keep their paths and reports distinct.
2. Audit upstream setup/Windows fixes separately before proposing a sync.
3. Verify Windows executable discovery, paths with spaces and the CLI alongside the GUI.
4. Preserve existing Claude config; inspect setup's backup/merge behavior before automating it.
5. Prove one tiny end-to-end project before installing optional tools.
6. Add video/Minecraft recipes as optional workflows, and label native integration as future work.
7. Test local inference independently before offering offline building.

## Verification boundary

Reviewed root `AGENTS.md`, `CLAUDE.md`, pitfalls, status, roadmap, extension guidance,
Claude integration docs, CLI setup/rebuild arguments, diagnostics, backend configuration,
target-kind registration, stack recipes, Build tools and Windows packaging source.
GitHub metadata verified the fork head, upstream comparison and release asset names/digest.

The first audit's environment had no Rust compiler and no Windows desktop (the setup PR's
environment has Rust 1.97 on Linux: see [REPORT.md](REPORT.md)). No cargo checks, Windows launch,
Claude authentication, MCP live handshake, local inference, rendered video, game or Minecraft
client test was run. Upstream test claims are upstream reports, not tests repeated here.
The referenced sibling `../craftrules/AGENTS.md` is absent from this checkout. Do not invent
its contents or make a personal fork depend on undocumented private sibling files.

## Primary sources

- [Fork baseline](https://github.com/Ardent6971/craft-anything/tree/2e4afc535cebb6ee556c5ea3f6b4e454487853f9)
- [Upstream snapshot](https://github.com/storytold/craft-anything/tree/ad5cd81b6a2ce5238024dadc9397ea0fc20170e5)
- [Release](https://github.com/storytold/craft-anything/releases/tag/v0.3.0)
- [Claude Code Windows setup](https://code.claude.com/docs/en/setup)
- [LM Studio system requirements](https://lmstudio.ai/docs/app/system-requirements)
- [LM Studio OpenAI-compatible API](https://lmstudio.ai/docs/developer/openai-compat)
