# Fork brief

## Goal

Prepare this fork so its owner can begin on a Windows desktop with a few clear steps,
then give Claude references or requests for websites, reels/videos, Minecraft projects,
games and other software. Prefer local execution and reusable project recipes.

This is repository context and workflow guidance. It does not train a model or give
Craft Anything capabilities merely by documenting them.

## Working defaults

- Target native Windows 10 and Windows 11, initially x64. Verify the actual OS and CPU before installing.
- Get the existing Craft Anything + Claude Code path working first. Use the owner's
  unmodified local Claude Code installation and its own sign-in flow.
- Local app, local generated files and local rendering do not mean offline AI.
  Claude Code needs its remote service; optional local inference is a separate backend.
- Keep setup modular: base application first, project-specific tools when needed.
  Do not install every game engine, model, Java version or media tool up front.
- A reference is input to analysis, not permission to publish or copy its assets.
  Preserve the app's Clean room/Deep distinction and its approval controls.
- Use supplied recordings and original assets for media work. A social-media URL alone
  does not guarantee accessible footage, editable source or a reproducible effect.
- Keep generated projects, footage, Minecraft worlds, credentials and model files outside
  this public source repository. Each deliverable gets its own folder and reproducible run instructions.
- Work on a named branch and open a PR. Routine setup implementation and validation are
  in scope; merging, publishing, paid services and remote changes to the home PC are not implied.

## How to answer the owner

Lead with what works and the next simple action. Label work as implemented, tested,
untested or blocked. Never call a setup perfect or a project ready because its docs exist,
its dependencies install, or a build exits successfully. Verify the actual result.

When working remotely while the owner is on a phone, finish everything available in the
current environment. Leave sign-in, local files and desktop-only checks as explicit steps;
do not pretend the remote machine is the owner's PC.

## Read next

- [Claude setup task](CLAUDE-SETUP.md): ordered work and completion gates.
- [Audit](AUDIT.md): pinned source findings and known gaps.
- [Windows start](WINDOWS-START.md): current manual route, before automation exists.
- [Workflows](WORKFLOWS.md): choose the right route for each request.
- [Local AI](LOCAL-AI.md): optional local backend and offline acceptance test.
