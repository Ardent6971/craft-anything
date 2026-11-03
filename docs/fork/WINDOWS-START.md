# Start on the Windows desktop

This is the current manual route. Automated fork installers/launchers have not been created
by this documentation change. Commands below were checked against source, not run on Windows.

## Fastest first trial

1. Install or locate the standalone **Claude Code CLI** using its
   [official Windows guide](https://code.claude.com/docs/en/setup).
   Having Claude chat on a phone or desktop does not prove the `claude` executable is installed.
   Git for Windows is recommended for Bash support; follow the current vendor requirements.
   Open a fresh PowerShell window, then run:

   ```powershell
   claude --version
   claude auth login
   claude auth status
   ```

   Complete any login in Anthropic's own browser flow. Keep credentials out of this repository.

2. For an x64 PC, download the [pinned v0.3.0 portable ZIP](https://github.com/storytold/craft-anything/releases/download/v0.3.0/craft-anything-0.3.0-windows-x64-portable.zip).
   Compare its `Get-FileHash -Algorithm SHA256` result with the value in [the audit](AUDIT.md),
   extract it into a permanent writable folder, and keep its files together.
   Use the matching ARM build instead on an ARM PC; do not infer architecture from Windows 11 alone.
   This trial runs the upstream release, not customized fork code.

3. Open PowerShell **inside the extracted folder that contains both EXE files**. Check it:

   ```powershell
   .\craft-anything-cli.exe --version
   .\craft-anything-cli.exe doctor
   .\craft-anything-cli.exe setup --client claude_code --dry-run
   ```

   Review the preview, then apply the connection:

   ```powershell
   .\craft-anything-cli.exe setup --client claude_code
   .\craft-anything-cli.exe doctor --client claude_code
   ```

   Normal setup asks before writing. Restart Claude Code after setup. Keep this folder in
   place because the registration uses its CLI path. Config backup/restore details must be
   recorded by Claude before any automated setup is delivered.

4. Launch `craft-anything.exe`. In Settings → AI, detect/add the local Claude Code agent
   and select it as the builder. MCP registration lets Claude use Craft Anything; selecting
   the builder lets Craft Anything invoke Claude. These are related but separate connections.
   If it cannot find the agent, use the app's program-path setting.
   Start with one build at a time, generated assets off, and a small first project.

5. Ask for an original static test page: “Make a plain HTML and CSS page with a title,
   three cards and one working button. No framework.” Verify that it opens, resizes and
   the button works. Optional CLI equivalent from the same extracted folder:

   ```powershell
   .\craft-anything-cli.exe rebuild - "Make a plain HTML and CSS page with three cards and one working button. No framework." --rounds 1
   ```

If diagnostics list a missing **optional** engine, install it only for a project that needs it.
If the builder or MCP check fails, stop there and use the exact remediation; do not install all engines.

## Development route for the fork

Use this when Claude's changes require a source build. Clone this fork and check out the
setup PR branch until it is merged; then use the reviewed default branch. Keep the source
checkout separate from generated projects and the portable release.

Requires Git, Rust/rustup meeting this checkout's `rust-version`, the MSVC C++ build tools
and Windows SDK. Node/npm are needed for web projects that actually use them, not for
the plain HTML trial. Resolve and verify current dependency versions at setup time.

In PowerShell at the repository root, run each command separately and stop on failure:

```powershell
rustc --version
cargo build --release --locked -p craft-anything -p craft-anything-cli
.\target\release\craft-anything-cli.exe doctor
.\target\release\craft-anything-cli.exe setup --client claude_code --dry-run
.\target\release\craft-anything-cli.exe setup --client claude_code
.\target\release\craft-anything-cli.exe doctor --client claude_code
.\target\release\craft-anything.exe
```

These paths assume the default Cargo target directory and native Windows target. If a custom
`CARGO_TARGET_DIR` or explicit target is used, use its actual output folder. Never rename
`craft-anything-cli.exe`; close running fork binaries before rebuilding them on Windows.
Do not lower the manifest's Rust requirement just to make an old compiler accept it.

## After the first project works

Choose a [workflow](WORKFLOWS.md). Local AI is optional; see [its separate test plan](LOCAL-AI.md).
The next setup implementation must reduce the home steps to: install missing prerequisites,
sign in, run the prepared setup, and launch. It must also list anything still untested.
