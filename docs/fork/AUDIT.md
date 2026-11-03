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

This environment has no Rust compiler and no Windows desktop. No cargo checks, Windows launch,
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
