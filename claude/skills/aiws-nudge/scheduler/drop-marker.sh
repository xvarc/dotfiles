#!/bin/bash
# aiws-nudge scheduler hook.
#
# launchd invokes this on the nudge cadence. It does NOT run Claude or touch
# Jira/Slack — the nudge is draft-first and needs an interactive session for
# MCP auth + Xan's confirmation. All this does is drop a marker file so that
# `hello` and `chief-of-staff` can remind Xan that a nudge is due (or that a
# scheduled one was missed) next time he's in a session.
#
# Usage: drop-marker.sh <kind>
#   kind = tue-nudge | thu-nudge | mon-missed-check
#
# Marker dir is machine-local (outside the git vault) to avoid commit churn.

set -euo pipefail

KIND="${1:?usage: drop-marker.sh <tue-nudge|thu-nudge|mon-missed-check>}"
MARKER_DIR="${HOME}/.claude/aiws-nudge/pending"
mkdir -p "$MARKER_DIR"

STAMP="$(date '+%Y-%m-%d %H:%M %Z')"
DOW="$(date '+%A')"
MARKER="${MARKER_DIR}/${KIND}.flag"

# One marker per kind; overwrite so a new week's trigger refreshes the date
# rather than piling up. hello/chief-of-staff clear it once acted on.
printf 'kind=%s\ndue=%s\nday=%s\n' "$KIND" "$STAMP" "$DOW" > "$MARKER"

# Log for debugging launchd firing.
echo "[$STAMP] dropped marker: $KIND" >> "${MARKER_DIR}/scheduler.log"
