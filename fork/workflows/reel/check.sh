#!/usr/bin/env bash
# Check a rendered reel's properties with ffprobe: ./check.sh FILE.mp4 [WIDTH HEIGHT FPS]
# Exits 1 when the size, codecs or frame rate differ from what was asked for (1080 1920 30).
set -euo pipefail
f=${1:?usage: check.sh FILE.mp4 [WIDTH HEIGHT FPS]}; w=${2:-1080}; h=${3:-1920}; fps=${4:-30}
v=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate,pix_fmt -of default=nw=1 "$f")
a=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate -of default=nw=1 "$f")
d=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f")
echo "$v" | sed 's/^/check: video /'; echo "${a:-none}" | sed 's/^/check: audio /'; echo "check: duration ${d}s"
bad=0
grep -qx "codec_name=h264" <<<"$v" || { echo "check: FAIL video codec is not H.264"; bad=1; }
grep -qx "width=$w" <<<"$v" && grep -qx "height=$h" <<<"$v" || { echo "check: FAIL size is not ${w}x${h}"; bad=1; }
grep -qx "r_frame_rate=$fps/1" <<<"$v" || { echo "check: FAIL frame rate is not $fps"; bad=1; }
grep -qx "pix_fmt=yuv420p" <<<"$v" || { echo "check: FAIL pixel format is not yuv420p (some players refuse it)"; bad=1; }
grep -qx "codec_name=aac" <<<"$a" || { echo "check: FAIL audio is not AAC"; bad=1; }
[[ $bad == 0 ]] && echo "check: ok (still watch the whole file: this checks properties, not content)"
exit $bad
