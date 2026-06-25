#!/bin/zsh
# SessionStart hook: surface Xan's active learning focuses into session context
# so evidence-based teaching is "present by default" (see the `learn` skill).
# Emits nothing if the focus list is absent, so it's safe on any machine.

FOCUS_FILE="$HOME/.claude/context/learning-focus.md"

if [ ! -f "$FOCUS_FILE" ]; then
  exit 0
fi

# Pull just the focus headings (the "## N. Title" lines) for a lightweight nudge,
# rather than injecting the whole file every session.
FOCUSES=$(grep -E '^## [0-9]+\. ' "$FOCUS_FILE" | sed 's/^## /  - /')

if [ -z "$FOCUSES" ]; then
  exit 0
fi

cat <<EOF
Xan has active learning focuses (full detail in ~/.claude/context/learning-focus.md):
$FOCUSES

When the current work genuinely exercises one of these, weave in teaching using the
\`learn\` skill — proportionate to the task, relevance-gated, not every turn. After
covering a topic, append a dated one-liner to that focus's Log in the file.
EOF
exit 0
