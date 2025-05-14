#!/usr/bin/env bash

# 0) If we're under the xscreensaver-demo (the preview), exit immediately
PPID=$(ps -o ppid= -p $$ | tr -d ' ')
GRANDPARENT=$(ps -o comm= -p "$PPID" | tr -d ' ')
if [[ "$GRANDPARENT" == "xscreensaver-demo" ]]; then
  exit 0
fi

# 1) Load quotes
quotes=()
while IFS= read -r line; do
  [[ -n "$line" ]] && quotes+=("$line")
done < /home/the-squid/quotes.txt

# 2) Read & increment index
if [[ -f "$STATEFILE" ]]; then
  last=$(<"$STATEFILE")
else
  last=-1
fi
idx=$(( (last + 1) % ${#quotes[@]} ))
echo "$idx" > "$STATEFILE"

# 3) Pick the quote
quote="${quotes[$idx]}"


# 3) Trap TERM and forward it to osd_cat
cleanup() {
  [[ -n "$OSD_PID" ]] && kill "$OSD_PID" 2>/dev/null
  exit 0
}
trap cleanup SIGTERM SIGINT

# 4) Launch osd_cat in foreground (so wait waits on it)
echo "$quote" | osd_cat \
  --pos=middle \
  --align=center \
  --delay=86400 \
  --font="-misc-fixed-medium-r-normal--30-*-*-*-*-*-iso8859-1" \
  --color=white \
  --shadow=1 \
  --outline=1 &
OSD_PID=$!

# 5) Wait for osd_cat to exit (or for TERM to arrive)
wait "$OSD_PID"