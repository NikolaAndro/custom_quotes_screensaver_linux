#!/usr/bin/env bash

exec 2> ~/quote_saver_debug.log
set -x

STATEFILE="$HOME/.cache/quote_saver_index"
mkdir -p "$(dirname "$STATEFILE")"

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

# 4) Cycle forever
idx=0
num=${#quotes[@]}
while true; do
  full="${quotes[$idx]}"

  # if there’s an author (marked by “ - ”), split out the two parts
  if [[ "$full" == *" - "* ]]; then
    text="${full% - *}"
    author="${full##* - }"
    # prepare a two-line display with a blank line in between
    display="$text"$'\n\n'"— $author"
  else
    display="$full"
  fi

  # show it for 300s (5 minutes)
  printf "%s\n" "$display" | osd_cat \
    --pos=middle \
    --align=center \
    --delay=300 \
    --font="-misc-fixed-medium-r-normal--30-*-*-*-*-*-iso8859-1" \
    --shadow=1 \
    --outline=1 &
  OSD_PID=$!

  # wait 300s (5 minutes) or until TERM
  sleep 300 & 
  SLEEP_PID=$!
  wait $SLEEP_PID 2>/dev/null

  # clear it
  kill "$OSD_PID" 2>/dev/null

  # advance index
  idx=$(( (idx+1) % num ))
done

# 5) Wait for osd_cat to exit (or for TERM to arrive)
wait "$OSD_PID"