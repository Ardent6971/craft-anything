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

Done in branch `claude/craftanything-windows-setup-gehpkc`: findings in `AUDIT.md`, evidence in `REPORT.md`.

- [x] Re-read remote heads, upstream diff and current release assets. Audit setup/Windows
  fixes since the recorded baseline. Recommend a pinned first-run baseline with reasons.
- [x] Propose upstream synchronization separately if useful; preserve fork changes and
  compare/run checks. Do not silently advance main or bundle a large sync with setup scripts.
- [x] Resolve current Windows prerequisites and their verified publisher URLs/versions.
  Separate base tools from optional project packs. Do not lower minimum Rust.
- [x] Record dependencies and reproducible commands in a public, non-secret setup report.

### F2 — base setup and launch helpers (depends on F1)

Implemented in `fork/windows/` (branch `claude/craftanything-windows-setup-gehpkc`); the setup/doctor/AI commands they call were run
for real on Linux with disposable folders; the PowerShell itself awaits a Windows run.

- [x] First reuse `doctor` and `setup`; avoid creating a competing config writer.
- [x] Provide a read-only preflight, repeatable setup and launcher with sensible defaults.
  On Windows, support PowerShell 5.1 or document and detect any newer requirement.
- [x] Offer a pinned portable application route for quick use and a separate fork source-build
  route. State clearly which version is running. Keep GUI and CLI together under their real names.
- [x] Validate downloads with publisher checksums/digests; do not execute unverified payloads.
- [x] Detect existing installs and use them when compatible. Quote paths with spaces, propagate
  exit codes, stop on failures and give one concrete next action. A second run must not corrupt setup.
- [x] Before configuration changes, inspect the existing setup backup/merge implementation,
  preserve unrelated MCP entries and record an exact restore procedure. Keep backups local.
- [x] Keep sign-in in Claude Code's own flow. Do not collect or print tokens.
- [x] Leave system-wide security settings alone. Do not add global execution-policy bypasses,
  blanket agent permission bypasses, or installers for every optional engine.
- [x] Do not auto-register in all detected clients; target the chosen Claude Code client.
- [ ] Do not claim scripts work on Windows until tested there: run `.github/workflows/fork-windows-setup.yml`
  (or the checklist in `REPORT.md`) on Windows and record the result.

### F3 — end-to-end base proof (depends on F2)

- [ ] Verify app launch, CLI discovery, `claude auth status`, selected builder, setup preview,
  applied MCP connection and doctor's live handshake on an available Windows machine.
  (All but app launch passed on Linux with the fork build; Windows pending.)
- [x] Produce a small original static website through the real workflow; open it at three
  widths and exercise its button/navigation. Record exact versions, output and limitations.
  (Linux, fork build + Claude Code 2.1.317; see `REPORT.md`. Repeat on Windows.)
- [ ] Test setup rerun and path-with-spaces behavior. Test backup/restore with disposable
  configuration. Never use the owner's real settings or live worlds as test fixtures.
  (CLI level done on Linux; the scripts' own rerun/restore are in the Windows CI workflow, not yet run.)
- [ ] Stopping a build (Linux, SIGINT) left the builder's running command behind: Claude Code puts
  tool commands in their own session, outside the CLI's process group. Check on Windows (Job
  Object) and decide on a fix upstream (see `REPORT.md`, finding 2).
- [x] If only Linux/cloud is available, complete what can be checked and leave Windows rows
  explicitly pending. Do not hold all useful preparation until the owner returns.

### F4 — optional workflow packs (depends on F2; native extension work waits for F3)

- [x] Website pack: browser discovery plus Node/npm only for stacks that need them.
- [x] Media pack: FFmpeg/ffprobe and a tiny local export from synthetic or supplied footage;
  optionally a reproducible coded-animation project. No footage/model downloads without need.
- [x] Minecraft pack: intake for edition/version/loader or server API, then compatible JDK
  and build wrapper; use disposable test instances. Prove a real output before offering a template.
  (Paper plugin template: JAR built with Paper API 1.21.11 on JDK 21. Fabric/NeoForge: no template.)
- [ ] Load the Paper template's JAR on a disposable Paper server and run `/hello` (not done: needs
  the server JAR and its EULA accepted by the owner).
- [x] Game pack: explicitly chosen engine; no default install of all game engines.
- [x] Add launch/build/export recipes and verify outputs. Keep external workflows labeled as
  external. Add native target kinds/checks only through the extension seams in a scoped follow-up.
- [ ] Follow-up (scoped, upstream-worthy): a request naming the "Plain HTML and CSS" stack but not
  the word "website" is built as an app, whose check wants a runnable program. Decide whether a
  web stack should imply the website kind (`crates/ai/src/rebuild/kinds/website.rs`).
- [ ] Follow-up: native video/Minecraft target kinds only after the external routes are used for
  real projects (`docs/extending.md`).

### F5 — optional local inference (depends on F2; does not block Claude-first setup)

- [ ] Follow `LOCAL-AI.md`: separate backend, real model id, modest context, no silent cloud fallback.
- [ ] Benchmark on the actual machine; report chat, tools, tiny build and offline results separately.
- [ ] Keep large models, provider spending and GPU-heavy generation optional.

### F6 — final desktop handoff (depends on F2; include all remaining F3–F5 gaps)

- [x] Update `WINDOWS-START.md` to exact delivered scripts and tested artifact names. Clearly
  distinguish published upstream binaries, fork source builds and proposed/unbuilt helpers.
- [x] Give the owner at most a few top-level steps: get the prepared version, install only
  missing base prerequisites, sign in, run setup/launch, then choose a project workflow.
- [x] Provide a concise verification report: commit SHA, OS, versions, actual commands,
  passed/failed/not-run checks, output locations, remaining desktop actions and rollback.
- [x] Open a PR with the exact implementation and evidence. Do not merge automatically.

## Completion standard

Use existing Rust layers, tool registration and process supervisor for app changes. Tool
effects and approval controls remain truthful. Run the repository's relevant fmt, tests,
clippy, layers, locks, secrets and any affected wasm/generated-doc checks; use `--locked`
where supported. A docs-only change does not prove the Rust application works. If a check
cannot run, state the exact missing prerequisite and keep it pending.

Success is a tested base path and an honest short home checklist. Optional unsupported
workflows must have a practical next route, rather than a promise that Craft Anything
can already turn any link into any finished product.
