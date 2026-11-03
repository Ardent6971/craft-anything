# Claude task: prepare the Windows workstation workflow

## Owner request

Prepare this fork while the owner is on a phone so starting at home is simple. It should
support a clear workflow for references/requests involving websites, reels/videos,
Minecraft mods or plugins, games and software, running locally wherever practical.
Finish useful remote work now; do not stop at a plan or claim access to the home desktop.

This task covers setup preparation and small changes needed for it, not a rewrite of the
engine or a promise that all project categories are natively supported.

## Start here

1. Read `CLAUDE.md`, `AGENTS.md`, `docs/pitfalls.md`, this folder's brief/audit/workflows,
   `docs/STATUS.md`, `docs/ROADMAP.md`, `docs/extending.md` and the source you will touch.
2. Check current branch, dirty files and remotes. Find the `docs/claude-windows-setup` PR
   if these docs are not yet on main; base your setup work on these docs without discarding
   other changes. Create a named `chore/` or `feature/` branch for implementation.
3. Use the fork lane in the roadmap. Claim one pending item before changing code, honor
   its dependencies and use small PRs. Do not merge or publish without owner direction.
4. If the upstream shared-rules sibling is absent, record it. Follow available rules and
   this explicit task; do not invent missing instructions or clone an unrelated project.

## Ordered setup queue

Track progress here as well as the root roadmap's fork lane. Pending means unimplemented
or not verified, not a request to pause for routine setup decisions.

### F1 — baseline and dependency audit (no prerequisite)

- [ ] Re-read remote heads, upstream diff and current release assets. Audit setup/Windows
  fixes since the recorded baseline. Recommend a pinned first-run baseline with reasons.
- [ ] Propose upstream synchronization separately if useful; preserve fork changes and
  compare/run checks. Do not silently advance main or bundle a large sync with setup scripts.
- [ ] Resolve current Windows prerequisites and their verified publisher URLs/versions.
  Separate base tools from optional project packs. Do not lower minimum Rust.
- [ ] Record dependencies and reproducible commands in a public, non-secret setup report.

### F2 — base setup and launch helpers (depends on F1)

- [ ] First reuse `doctor` and `setup`; avoid creating a competing config writer.
- [ ] Provide a read-only preflight, repeatable setup and launcher with sensible defaults.
  On Windows, support PowerShell 5.1 or document and detect any newer requirement.
- [ ] Offer a pinned portable application route for quick use and a separate fork source-build
  route. State clearly which version is running. Keep GUI and CLI together under their real names.
- [ ] Validate downloads with publisher checksums/digests; do not execute unverified payloads.
- [ ] Detect existing installs and use them when compatible. Quote paths with spaces, propagate
  exit codes, stop on failures and give one concrete next action. A second run must not corrupt setup.
- [ ] Before configuration changes, inspect the existing setup backup/merge implementation,
  preserve unrelated MCP entries and record an exact restore procedure. Keep backups local.
- [ ] Keep sign-in in Claude Code's own flow. Do not collect or print tokens.
- [ ] Leave system-wide security settings alone. Do not add global execution-policy bypasses,
  blanket agent permission bypasses, or installers for every optional engine.
- [ ] Do not auto-register in all detected clients; target the chosen Claude Code client.
  Do not claim scripts work on Windows until tested there.

### F3 — end-to-end base proof (depends on F2)

- [ ] Verify app launch, CLI discovery, `claude auth status`, selected builder, setup preview,
  applied MCP connection and doctor's live handshake on an available Windows machine.
- [ ] Produce a small original static website through the real workflow; open it at three
  widths and exercise its button/navigation. Record exact versions, output and limitations.
- [ ] Test setup rerun and path-with-spaces behavior. Test backup/restore with disposable
  configuration. Never use the owner's real settings or live worlds as test fixtures.
- [ ] If only Linux/cloud is available, complete what can be checked and leave Windows rows
  explicitly pending. Do not hold all useful preparation until the owner returns.

### F4 — optional workflow packs (depends on F2; native extension work waits for F3)

- [ ] Website pack: browser discovery plus Node/npm only for stacks that need them.
- [ ] Media pack: FFmpeg/ffprobe and a tiny local export from synthetic or supplied footage;
  optionally a reproducible coded-animation project. No footage/model downloads without need.
- [ ] Minecraft pack: intake for edition/version/loader or server API, then compatible JDK
  and build wrapper; use disposable test instances. Prove a real output before offering a template.
- [ ] Game pack: explicitly chosen engine; no default install of all game engines.
- [ ] Add launch/build/export recipes and verify outputs. Keep external workflows labeled as
  external. Add native target kinds/checks only through the extension seams in a scoped follow-up.

### F5 — optional local inference (depends on F2; does not block Claude-first setup)

- [ ] Follow `LOCAL-AI.md`: separate backend, real model id, modest context, no silent cloud fallback.
- [ ] Benchmark on the actual machine; report chat, tools, tiny build and offline results separately.
- [ ] Keep large models, provider spending and GPU-heavy generation optional.

### F6 — final desktop handoff (depends on F2; include all remaining F3–F5 gaps)

- [ ] Update `WINDOWS-START.md` to exact delivered scripts and tested artifact names. Clearly
  distinguish published upstream binaries, fork source builds and proposed/unbuilt helpers.
- [ ] Give the owner at most a few top-level steps: get the prepared version, install only
  missing base prerequisites, sign in, run setup/launch, then choose a project workflow.
- [ ] Provide a concise verification report: commit SHA, OS, versions, actual commands,
  passed/failed/not-run checks, output locations, remaining desktop actions and rollback.
- [ ] Open a PR with the exact implementation and evidence. Do not merge automatically.

## Completion standard

Use existing Rust layers, tool registration and process supervisor for app changes. Tool
effects and approval controls remain truthful. Run the repository's relevant fmt, tests,
clippy, layers, locks, secrets and any affected wasm/generated-doc checks; use `--locked`
where supported. A docs-only change does not prove the Rust application works. If a check
cannot run, state the exact missing prerequisite and keep it pending.

Success is a tested base path and an honest short home checklist. Optional unsupported
workflows must have a practical next route, rather than a promise that Craft Anything
can already turn any link into any finished product.
