#!/bin/zsh
# PostToolUse hook: notify Xan on Slack when Notes/To Do.md is edited.
# Receives hook context on stdin as JSON.
# Only fires for Edit/Write tool calls that touch the To Do file.

INPUT=$(cat)

# Check if this tool call touched To Do.md
TOOL=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
FILE=$(echo "$INPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', inp.get('path', '')))
" 2>/dev/null)

# Only act on Edit or Write to the To Do file
if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" ]]; then
  exit 0
fi

if [[ "$FILE" != *"To Do.md"* ]]; then
  exit 0
fi

MSG="📋 *To Do.md updated* — Claude edited the AIWS task list. Check it: \`Notes/To Do.md\` in the vault, or pull the repo on your other machine."

~/.claude/hooks/slack-post-dm.sh "$MSG"

exit 0
