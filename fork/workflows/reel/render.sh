#!/usr/bin/env bash
# Render a vertical reel (1080x1920, H.264 + AAC, MP4) from local clips, with captions burned in.
#
#   ./render.sh [--preview] OUTPUT.mp4 CLIP1 [CLIP2 ...]
#
# Environment (all optional):
#   CAPTIONS=captions.srt   subtitles to burn in (a path relative to this folder; no drive letters)
#   MUSIC=music.m4a         a music bed mixed under the clips' own sound
#   MUSIC_VOLUME=0.25       its volume
#   FPS=30                  frame rate of the result
#   CRF=20                  quality (lower is better and bigger)
#
# --preview renders the first 6 seconds at 540x960, fast, to check framing and captions.
# Clips are scaled to fill the frame and centre-cropped; a clip without sound gets silence.
# Originals are only read, never changed. Works in Git Bash on Windows (Claude Code's shell),
# Linux and macOS. Needs ffmpeg and ffprobe on PATH; captions need an ffmpeg built with libass.
set -euo pipefail

preview=0
if [[ "${1:-}" == "--preview" ]]; then preview=1; shift; fi
if [[ $# -lt 2 ]]; then
  sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi
out=$1; shift
for tool in ffmpeg ffprobe; do
  command -v "$tool" >/dev/null || { echo "render: $tool not found on PATH" >&2; exit 3; }
done
for c in "$@"; do [[ -f "$c" ]] || { echo "render: no such clip: $c" >&2; exit 2; }; done
if [[ -e "$out" ]]; then
  for c in "$@"; do [[ "$c" -ef "$out" ]] && { echo "render: refusing to overwrite an input: $out" >&2; exit 2; }; done
fi

fps=${FPS:-30}; crf=${CRF:-20}; w=1080; h=1920; preset=medium
if [[ $preview == 1 ]]; then w=540; h=960; preset=veryfast; fi

inputs=(); filters=""; n=0
for c in "$@"; do
  inputs+=(-i "$c")
  vf="[$n:v:0]scale=${w}:${h}:force_original_aspect_ratio=increase,crop=${w}:${h},setsar=1,fps=${fps},format=yuv420p[v$n]"
  if [[ -n "$(ffprobe -v error -select_streams a:0 -show_entries stream=index -of csv=p=0 "$c")" ]]; then
    af="[$n:a:0]aresample=48000,aformat=channel_layouts=stereo[a$n]"
  else
    dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$c")
    af="anullsrc=r=48000:cl=stereo,atrim=0:${dur}[a$n]"
  fi
  filters+="$vf;$af;"
  n=$((n + 1))
done
pairs=""; for ((i = 0; i < n; i++)); do pairs+="[v$i][a$i]"; done
filters+="${pairs}concat=n=${n}:v=1:a=1[vcat][acat]"

vlast="[vcat]"
if [[ -n "${CAPTIONS:-}" ]]; then
  [[ -f "$CAPTIONS" ]] || { echo "render: no such captions file: $CAPTIONS" >&2; exit 2; }
  size=$(( h / 20 ))
  filters+=";[vcat]subtitles=${CAPTIONS}:force_style='Fontsize=${size},PlayResX=${w},PlayResY=${h},Alignment=2,MarginV=$(( h / 8 )),Outline=3,BorderStyle=1'[vsub]"
  vlast="[vsub]"
fi
alast="[acat]"
if [[ -n "${MUSIC:-}" ]]; then
  [[ -f "$MUSIC" ]] || { echo "render: no such music file: $MUSIC" >&2; exit 2; }
  inputs+=(-i "$MUSIC")
  filters+=";[$n:a:0]aresample=48000,volume=${MUSIC_VOLUME:-0.25}[mus];[acat][mus]amix=inputs=2:duration=first:dropout_transition=0[amix]"
  alast="[amix]"
fi

limit=(); [[ $preview == 1 ]] && limit=(-t 6)
ffmpeg -hide_banner -loglevel error -y "${inputs[@]}" -filter_complex "$filters" \
  -map "$vlast" -map "$alast" "${limit[@]}" \
  -c:v libx264 -preset "$preset" -crf "$crf" -pix_fmt yuv420p -r "$fps" \
  -c:a aac -b:a 160k -ar 48000 -movflags +faststart "$out"
echo "render: wrote $out"
"$(dirname "$0")/check.sh" "$out" "$w" "$h" "$fps"
