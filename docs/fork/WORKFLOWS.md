# Route each request to the right workflow

Two kinds of route, kept apart on purpose:

- **Built in**: Craft Anything already has the target kind, stacks and checks (website, game,
  app). Use the app's Make screen or `craft-anything-cli rebuild`; Claude Code is the builder.
- **External**: Claude Code works in an ordinary project folder with local tools, using
  templates from [`fork/workflows`](../../fork/workflows). Craft Anything has **no** video or
  Minecraft target kind; adding one is extension work (`docs/extending.md`), not done here.

| Request | Route | Built in? | Starter | Local tools | Proof before calling it done |
|---|---|---|---|---|---|
| Website from screenshots/URL/description | Craft Anything build; say **"website"** and "plain HTML and CSS" or the framework | Yes | `new-project.cmd -Kind website` (intake only) | Edge/Chrome; Node only for framework stacks | Opens; desktop/tablet/phone widths; links and buttons work |
| Small new game | Craft Anything build, engine named: "in Godot" / `--build-with godot`, or "in Rust" / `--build-with rust` | Yes | `-Kind game` (intake only) | Only that engine (Unity is the default if none is named) | Starts, one play loop, restart; the built-in self-test is extra evidence |
| Desktop or console app | Craft Anything build, stack named | Yes | `-Kind app` | That stack's toolchain | Launches; the asked-for behaviour works |
| Reel/video from your recordings | External: `fork/workflows/reel` (`render.sh`, `check.sh`) in Git Bash | No | `-Kind reel` | FFmpeg + ffprobe | `check.sh` passes (1080×1920, H.264/AAC, fps) **and** you watched it all |
| Minecraft Paper/Spigot plugin | External: `fork/workflows/minecraft-paper` (Gradle wrapper) | No | `-Kind minecraft-paper` | JDK matching the server version | JAR builds; loads on a disposable server; command/event works in game |
| Minecraft Fabric/NeoForge mod, resource/data pack | External, from the loader's own template for the exact version | No | none yet (not proven) | JDK, loader toolchain, test client | Builds; launches in that exact client; feature shown; logs clean |
| Existing Unity/Unreal/Godot project | Its own repository and editor version | Partly (study in Deep mode) | — | The project's editor | Project's tests, play check, requested build |

Found in the live test for this PR: a request for "a plain HTML and CSS **page**" is classified
as an **app** (the website kind listens for "website", "web page", "landing page", " site "), so
the build check wanted a runnable program and the builder wrote a launcher script to satisfy it.
Say "website" or "web page". (Logged as a pending roadmap line under F4.)

## Universal intake

Record: desired result, input files/links, target platform/version, stack if specified,
what may change, what must stay, output location and acceptance criteria. Reuse known
answers; ask only for missing facts that change compatibility or the result.

Keep an input/reference folder, editable source, outputs and a small README with exact
build/run commands. Separate facts observed in a reference from guesses. Use a dated
status note with verified results and remaining work so another Claude session can continue.
For Craft Anything-managed projects, use its existing `craft.json`, capture, app and checks
structure rather than inventing a conflicting project schema.

## Websites

Specify “plain HTML/CSS” for a simple site or name the desired framework. Do not silently
replace a requested stack. Inspect all relevant pages and states; compare at desktop,
tablet and phone widths. A screenshot match does not prove forms or backend features work.
Keep preview local unless deployment is requested.

Starter request: “Study these references and build an original responsive website in plain
HTML and CSS. Match the layout and visual qualities, use original branding, and verify
the navigation and buttons at desktop, tablet and phone sizes.”

## Reels and videos

Use owner-supplied local recordings as the first working path. References can guide pacing,
typography and transitions; verify access before claiming to have studied an Instagram reel.
Do not treat a screenshot of a video or a guessed storyboard as analysis of its motion.

Start with cuts, scale/crop, captions, simple animation and audio using a reproducible local
render pipeline. Add generated footage, voice or paid assets only if specifically chosen.
For a vertical delivery, a useful initial spec is 1080 × 1920, MP4/H.264, AAC audio if present,
and an explicitly chosen frame rate/duration. Verify with ffprobe and watch the whole export.
Keep the editable project and source footage; never overwrite the original recording.

Before promising a native media feature, first prove a short export externally. Then propose
a `TargetKind`, media checks and tool/stack integration through `docs/extending.md`.
Do not claim that other Craft App Suite projects are installed or integrated automatically.

Starter request: “Use my recording to make a 20-second vertical reel. Preserve the app's real
appearance, add readable captions and restrained motion, and deliver an MP4 plus editable
source and the exact render command. Show a short preview before the full render.”

## Minecraft

First identify Java Edition versus Bedrock, then mod versus server plugin versus resource/data
pack. Confirm the exact game version and loader/server API before choosing dependencies.
Fabric, Forge and NeoForge are different targets; a standalone game build is not a mod.
For an existing project, retain its loader and wrapper unless migration is requested.

Use vendor documentation for the selected version to pin the JDK, loader, mappings and
build plugin. Create the actual Gradle wrapper from a trusted distribution/template and verify
it; do not fabricate wrapper JARs or mark a text-only skeleton ready. Keep dependency locks
where supported. Test on a disposable local instance/world; keep the live network separate.

Starter request: “Create a [mod/plugin/pack] for Minecraft [exact version] using [loader/API].
Implement [feature]. Pin compatible dependencies, build the distributable, and give the test
instance steps and expected behavior. Report client/server testing separately from compilation.”

## Games

Name the intended engine to avoid the built-in default choosing an unwanted large install.
For a small original prototype, choose a light workflow explicitly. Existing projects keep
their engine and version. Build one playable loop first, then add complexity.
Craft Anything's generated self-test is useful but must be supplemented by launch and play
checks. Assets, saves and packaging need their own validation; “Ready” is not a guarantee
that a full game or commercial-scale recreation is complete.
