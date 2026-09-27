#!/usr/bin/env bash
# Health check for all meiot.site pages.
#
# Usage:
#   ./scripts/health-check.sh                     # checks https://meiot.site
#   ./scripts/health-check.sh http://localhost    # checks a local instance
#   BASE=https://staging.meiot.site ./scripts/health-check.sh
#
# Exit code:
#   0 -> all pages healthy
#   1 -> one or more pages failed

set -u

BASE="${1:-${BASE:-https://meiot.site}}"
BASE="${BASE%/}"   # strip trailing slash

PAGES=(
  ""                # root should serve the birthday page
  "birthday.html"
  "sleep.html"
  "nup.html"
  "fiting.html"
  "christmas.html"
  "newyear.html"
  "valentine.html"
  "halloween.html"
  "miss.html"
  "women.html"
  "game.html"
)

# Colors (auto-off if not a TTY)
if [ -t 1 ]; then
  GREEN=$'\e[32m'; RED=$'\e[31m'; YELLOW=$'\e[33m'; DIM=$'\e[2m'; BOLD=$'\e[1m'; RESET=$'\e[0m'
else
  GREEN=""; RED=""; YELLOW=""; DIM=""; BOLD=""; RESET=""
fi

printf "\n%sChecking %s%s\n" "$BOLD" "$BASE" "$RESET"
printf "%s%-24s %-6s %-8s %-9s %s%s\n" "$DIM" "URL" "HTTP" "TIME" "SIZE" "STATUS" "$RESET"
printf "%s%s%s\n" "$DIM" "$(printf '%*s' 70 '' | tr ' ' '-')" "$RESET"

fail=0
total=0
ok=0

for p in "${PAGES[@]}"; do
  total=$((total + 1))
  url="${BASE}/${p}"

  # -o /dev/null      discard body
  # -s                silent
  # -L                follow redirects (so 301 -> 200 counts as healthy)
  # -w "..."          write metrics
  # --max-time 15     don't hang forever
  read -r code time_total size_download <<< "$(
    curl -s -L -o /dev/null --max-time 15 \
      -w '%{http_code} %{time_total} %{size_download}' \
      "$url" 2>/dev/null || echo '000 0 0'
  )"

  # decide healthy: 200-399 counts as OK
  status_color="$GREEN"; status_txt="OK"
  if [[ "$code" -lt 200 || "$code" -ge 400 ]]; then
    status_color="$RED"; status_txt="FAIL"
    fail=$((fail + 1))
  else
    ok=$((ok + 1))
  fi

  # pretty format
  ms=$(awk -v t="$time_total" 'BEGIN { printf "%.0fms", t * 1000 }')
  kb=$(awk -v b="$size_download" 'BEGIN { printf "%.1fKB", b / 1024 }')
  display_p="${p:-/}"

  printf "%-24s %s%-6s%s %-8s %-9s %s%s%s\n" \
    "$display_p" "$status_color" "$code" "$RESET" "$ms" "$kb" \
    "$status_color" "$status_txt" "$RESET"
done

printf "%s%s%s\n" "$DIM" "$(printf '%*s' 70 '' | tr ' ' '-')" "$RESET"
if [ "$fail" -eq 0 ]; then
  printf "%s✓ All %d pages healthy%s\n\n" "$GREEN$BOLD" "$total" "$RESET"
  exit 0
else
  printf "%s✗ %d of %d pages FAILED%s\n\n" "$RED$BOLD" "$fail" "$total" "$RESET"
  exit 1
fi
