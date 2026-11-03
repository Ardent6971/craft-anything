#!/usr/bin/env bash
# Make synthetic test footage (no downloads): two short clips, one landscape with a tone and one
# square without sound, plus captions. ./make-sample.sh [FOLDER]   (default: sample/)
set -euo pipefail
d=${1:-sample}; mkdir -p "$d"
ffmpeg -hide_banner -loglevel error -y -f lavfi -i "testsrc2=size=1920x1080:rate=30:duration=3" \
  -f lavfi -i "sine=frequency=440:duration=3" -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest "$d/clip-landscape.mp4"
ffmpeg -hide_banner -loglevel error -y -f lavfi -i "smptebars=size=1080x1080:rate=25:duration=2" \
  -c:v libx264 -pix_fmt yuv420p "$d/clip-square-silent.mp4"
cat > "$d/captions.srt" <<'SRT'
1
00:00:00,300 --> 00:00:02,600
This is a test caption

2
00:00:03,100 --> 00:00:04,800
Second clip, no sound of its own
SRT
echo "make-sample: wrote $d/clip-landscape.mp4, $d/clip-square-silent.mp4, $d/captions.srt"
