# Route each request to the right workflow

These are proposed operating recipes, not newly implemented native features. Use existing
Craft Anything routes when they fit; otherwise let Claude work in a separate project with
the required tools. Do not feed every input into the game-rebuild route.

| Request | Starting route | Additional local tooling | Required proof |
|---|---|---|---|
| Website from screenshots/URL | Existing website workflow; specify framework or plain HTML | Browser; Node/npm only for a chosen JS build stack | Build and open; responsive layouts; working navigation and interactions |
| Reel/video from supplied footage | Claude-led external media project first | FFmpeg/ffprobe; optionally Remotion for coded motion graphics or Blender for 3D | Play final MP4; check picture, sound, captions, timing and export properties |
| Minecraft Java mod | Separate mod project; Claude uses Craft Anything only for relevant inspection | Matching JDK, pinned loader/build plugin, Gradle wrapper, test client | Build distributable JAR; launch exact client; demonstrate feature; inspect logs |
| Minecraft Paper plugin | Separate plugin project, not a client mod | Matching JDK/API and Gradle or Maven; disposable test server | Build JAR; boot isolated server; exercise commands/events; inspect logs |
| Minecraft resource/data pack | Separate versioned pack project | Image tools if needed; matching Minecraft test instance | Valid metadata/layout and in-game behavior/appearance |
| New small game | Existing game workflow with an explicit stack, e.g. Godot | Only that engine and export tools | Build/export; launch; play loop; reset/restart; keep self-test evidence |
| Existing Unity/Unreal/Godot game | Work in its own repository with matching editor/version | Project's actual editor, modules and SDKs | Project tests, play check and requested target build |
| Other desktop software | Existing app workflow; explicitly name desired stack | Runtime/build tools selected for that project | Launch and verify required behavior; inspect real errors |

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

Starter request: “Study these references and build an original responsive site in plain
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
