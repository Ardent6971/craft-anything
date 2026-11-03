# Fork additions

Kept apart from upstream's code so upstream syncs stay simple. Nothing here changes the Rust app.

- `windows/`: setup for a Windows PC. Start with `check.cmd`, then `setup.cmd`, then `start.cmd`.
  The checklist is [docs/fork/WINDOWS-START.md](../docs/fork/WINDOWS-START.md).
- `workflows/`: project templates. Website, game and app requests use Craft Anything's own
  build; `reel/` (FFmpeg) and `minecraft-paper/` (Gradle) are external workflows Claude Code runs
  in an ordinary folder. Routes: [docs/fork/WORKFLOWS.md](../docs/fork/WORKFLOWS.md).

What was tested, where, and what still needs Windows: [docs/fork/REPORT.md](../docs/fork/REPORT.md).
