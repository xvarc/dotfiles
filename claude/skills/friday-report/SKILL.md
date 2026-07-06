---
name: friday-report
description: >
  Draft Xan's Friday weekly report for AIWS — a short, plain-text bullet update
  covering latest items and upcoming items. Run when Xan says "friday report",
  "weekly report", or "weekly update". Reads live tracking docs, produces a
  draft in Xan's voice ready to copy-paste.
tools: Read, Glob, Grep, Bash
---

# friday-report — weekly status update

Drafts Xan's Friday weekly update for the AIWS program. Short, plain, no
unnecessary preamble. The output should be ready to send with minimal editing.

---

## What this report is

A brief summary of the week — what happened and what's coming — for Woven
stakeholders (Justin, team). Not a status report with every open item. Two
sections, bullet format:

- **This week** — 3–5 bullets, most significant things that happened or moved
- **Next week** — 3–5 bullets, concrete upcoming milestones or actions

Keep it factual and specific. Named outputs, decisions, or meetings, not vague
progress language.

---

## Steps

### 1. Read program state
Read the tracking docs to understand current state:
- `Notes/To Do.md` — most recently completed items (checked off `[x]`) and
  top active priorities
- `Notes/Decisions.md` — anything settled this week
- `meetings/` — list recent distilled meeting files; any from this week are
  direct inputs to "This week"

```bash
ls -lt /Users/xan.varcoe/code/wp-work/AIWS-local/meetings/ | head -10
```

Also check the session-handoff for any load-bearing facts not in tracking docs.

### 2. Identify what "this week" is
Use today's date to determine the Mon–Fri window. Any meeting distilled files,
decisions settled, or `[x]` items completed in that window are "this week"
material. Be specific — cite what moved, not that "progress was made".

### 3. Identify what "next week" is
From To Do active priorities and Timeline milestones: what's actually scheduled
or due next week? Prefer concrete deliverables over process steps. Flag any
dependencies blocking next week's items if they're relevant to the reader.

### 4. Draft in Xan's voice (Gear 2)
Follow the xan-voice skill conventions:
- Direct, no throat-clearing
- Short bullets, one idea each
- No em dashes or hyphens in prose or bullets (rule from memory)
- Specific dates, names, and outputs — not vague summaries
- Professional async (Gear 2): structured but conversational

Format:
```
**This week**
- [bullet]
- [bullet]
- [bullet]

**Next week**
- [bullet]
- [bullet]
- [bullet]
```

### 5. Present and offer to copy
Output the draft directly to the conversation. Offer to copy to clipboard
(`pbcopy`) once Xan has reviewed, per the Slack message convention (temp file +
pbcopy; never print in terminal with line-break issues).

---

## Notes
- Do not invent progress. If a To Do item has no `[x]` and no meeting note
  confirms it moved, don't claim it happened.
- If this week was light (e.g. a holiday), say so with one bullet rather than
  padding.
- The report is for Woven-internal use — don't surface TMC-confidential details
  or internal risk framing intended for Xan only.
- Keep bullets to one line each where possible.
