#!/bin/zsh
# Post a message to Xan's Slack DM with himself.
# Usage: slack-post-dm.sh "message text"
# Extracts the Claude Code MCP Slack OAuth token from the macOS keychain at runtime.
# Fails softly — never blocks the hook chain.

SLACK_USER_ID="U04J9QHDDNZ"
MESSAGE="${1:-}"

if [ -z "$MESSAGE" ]; then
  echo "slack-post-dm.sh: no message provided" >&2
  exit 0
fi

# Extract token from Claude Code keychain entry (refreshed by Claude Code automatically)
TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for k, v in d.get('mcpOAuth', {}).items():
        if 'slack' in k:
            t = v.get('accessToken', '')
            if t:
                print(t)
                break
except:
    pass
" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "slack-post-dm.sh: no Slack token in keychain — skipping" >&2
  exit 0
fi

# Encode message as JSON string and post
ENCODED=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$MESSAGE" 2>/dev/null)
if [ -z "$ENCODED" ]; then
  echo "slack-post-dm.sh: failed to JSON-encode message" >&2
  exit 0
fi

RESPONSE=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data "{\"channel\":\"$SLACK_USER_ID\",\"text\":$ENCODED}" 2>/dev/null)

OK=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(str(d.get('ok',False)).lower())" 2>/dev/null)

if [ "$OK" != "true" ]; then
  ERR=$(echo "$RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('error','unknown'))" 2>/dev/null)
  echo "slack-post-dm.sh: Slack API error: $ERR" >&2
fi

exit 0  # always exit 0 — never block hooks
