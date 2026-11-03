# Craft projects

This folder holds one subfolder per project. It was created by Craft Anything's fork setup
(`New-CraftProject.ps1`); edit it freely. Each project keeps its own `INTAKE.md` (what was asked)
and `STATUS.md` (what was verified, what is left).

## Route each request

| Request | Route | Native in Craft Anything? |
|---|---|---|
| Website from screenshots, a URL or a description | Craft Anything build (`rebuild`, or the app's Make screen); say "plain HTML and CSS" or name the framework | Yes: website kind, web stacks, website checks |
| Small game | Craft Anything build with the engine named: "in Godot" (`--build-with godot`) or "in Rust" (`--build-with rust`, needs Rust) | Yes: game kind. Unity is the default if no engine is named: always name one |
| Desktop or command-line app | Craft Anything build, stack named ("in Python", "in Electron", "in Rust") | Yes: app kind |
| Reel or video from my recordings | `reel/` workflow here: `render.sh` with FFmpeg | No: external workflow; Craft Anything has no video kind |
| Minecraft Paper/Spigot server plugin | `minecraft-paper/` template (Gradle wrapper) | No: external workflow |
| Minecraft Fabric/NeoForge mod, resource or data pack | Separate project from the loader's own template for the exact version | No: external workflow, no template here yet |

## Rules for every project

- Ask only for what changes the result: target platform/version, stack, what must stay, where
  the output goes, how we will know it works. Write the answers in `INTAKE.md`.
- Keep originals read-only in `input/`. Editable source in the project, outputs in `output/`.
- References guide the work; don't copy their assets, names or branding.
- Record in `STATUS.md` the exact commands run and what was verified (opened, played, watched,
  joined a test server). "It compiled" is not "it works".
- No paid generation, publishing or uploads unless asked.
