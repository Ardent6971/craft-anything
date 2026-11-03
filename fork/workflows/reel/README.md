# Reel workflow (external: FFmpeg, not a Craft Anything feature)

Turns your own recordings into a vertical MP4 (1080 x 1920, H.264, AAC, 30 fps by default) with
captions burned in and an optional music bed. Runs locally; nothing is uploaded or generated.
On Windows run the scripts in **Git Bash** (installed with Git for Windows; Claude Code uses it
too) from this folder. Needs `ffmpeg` and `ffprobe` on PATH (e.g. `winget install Gyan.FFmpeg`,
whose builds include libass for captions); `check.cmd` in fork/windows reports them.

```bash
./make-sample.sh                       # optional: synthetic test clips + captions in sample/
CAPTIONS=sample/captions.srt ./render.sh --preview output/preview.mp4 sample/*.mp4   # 6 s, 540x960
CAPTIONS=input/captions.srt MUSIC=input/music.m4a ./render.sh output/reel.mp4 input/clip1.mp4 input/clip2.mp4
./check.sh output/reel.mp4             # size, codecs, frame rate, duration
```

- Clips are scaled to fill the frame and centre-cropped, in the order given; a clip without sound
  gets silence. Trim clips first (`ffmpeg -ss 2 -to 7 -i in.mp4 -c copy input/clip1.mp4`) or ask
  Claude to.
- Captions: an `.srt` file, path relative to this folder (no `C:` paths: FFmpeg's subtitle filter
  reads the colon as an option separator).
- `check.sh` checks properties only. Watch the whole result before using it.
- Originals in `input/` are only read. The render refuses to overwrite one of its inputs.

Verified on synthetic clips on Linux (FFmpeg 6.1.1) and in Git Bash on a Windows CI runner
(FFmpeg from Chocolatey); see docs/fork/REPORT.md. Not yet run on your own recordings. Coded motion graphics (Remotion, Blender) are possible next steps, added only
when a project needs them.
