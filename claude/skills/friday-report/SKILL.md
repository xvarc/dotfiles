---
name: friday-report
description: >
  Draft Xan's Friday weekly report for AIWS — a short, plain-text bullet update
  covering latest items and upcoming items. Run when Xan says "friday report",
  "weekly report", or "weekly update". Reads live tracking docs, saves the
  report to Notes/archive/weekly-reports/YYYY-MM-DD.md, then copies to clipboard.
tools: Read, Glob, Grep, Bash
---

# friday-report — weekly status update

Drafts Xan's Friday weekly update for the AIWS program. Short, plain, no
unnecessary preamble. Saves the report to a dated file and copies it to the
clipboard — never rely on terminal output for copying (line break issues).

---

## What this report is

A brief summary of the week for Woven stakeholders (Justin, team). Two sections,
bullet format:

- **This week** — 3–5 bullets, most significant things that happened or moved
- **Next week** — 3–5 bullets, concrete upcoming milestones or actions

Keep it factual and specific. Named outputs and decisions, not vague progress
language. Do NOT reference internal documents, internal doc names, Jira ticket
numbers, or internal systems — the report is for stakeholders who don't have
access to those.

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

Also check `Notes/session-handoff.md` for any load-bearing facts not in
tracking docs.

### 2. Identify what "this week" is
Use today's date to determine the Mon–Fri window. Any meeting distilled files,
decisions settled, or `[x]` items completed in that window are "this week"
material. Be specific — cite what moved, not that "progress was made".

### 3. Identify what "next week" is
From To Do active priorities and Timeline milestones: what's actually scheduled
or due next week? Prefer concrete deliverables over process steps.

### 4. Draft in Xan's voice (Gear 2)
Follow the xan-voice skill conventions:
- Direct, no throat-clearing
- Short bullets, one idea each
- No em dashes or hyphens in prose or bullets
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

### 5. Save to archive and copy to clipboard
Save the report (content only, no preamble) to a dated file:

```
Notes/archive/weekly-reports/YYYY-MM-DD.md
```

Create the directory if it doesn't exist. Then copy the file contents to
clipboard using a temp file + pbcopy (never pipe multi-line text directly in
the terminal):

```bash
mkdir -p /Users/xan.varcoe/code/wp-work/AIWS-local/Notes/archive/weekly-reports
cat /path/to/file | pbcopy
```

Tell Xan the file was saved and is on the clipboard, ready to paste.

### 6. Show the report to Xan
Print the saved content to the conversation so Xan can review it before
sending. Invite any corrections — if corrections are given, update the file,
re-copy to clipboard, and confirm.

### 7. Post to Confluence Weekly Reporting page
After Xan confirms the content, post it to the shared Confluence page:
- **Page:** `https://woven-dojo.atlassian.net/wiki/x/BQDFeQ` (page ID `2042953733`, space `DOJO`)
- **cloudId:** `ecbaa248-3747-4626-befe-7babe1f98b0a`

**How the page works:** There is an empty project template table at the top of
the page. Each week, copy that template table and fill in the AIWS row with
the new content. Do NOT edit the existing template — add a new copy below the
date heading with today's date.

Fetch the current page HTML first (`mcp__atlassian__getConfluencePage`,
`contentFormat: html`), find the empty template table, duplicate it, fill in
the AIWS section with this week's bullets, and post the full updated page back
with `mcp__atlassian__updateConfluencePage`.

The AIWS table structure has three rows: **Project** (header), **Project Owner**
(Xan's mention, user ID `63c4dfaa176040ff3bd146d5`), **Updates and Plans**
(this week + next week bullets), and **Issues or Blockers** (if any; otherwise
leave blank). Match the existing table's HTML structure exactly — preserve all
`data-local-id` attributes on existing nodes; omit `data-local-id` on new nodes.

---

## Notes
- Do not invent progress. If a To Do item has no `[x]` and no meeting note
  confirms it moved, don't claim it happened.
- If this week was light, say so with one bullet rather than padding.
- Never reference internal documents, Jira tickets, or vault file paths in the
  report content — the audience does not have access to these.
- Keep bullets to one line each where possible.
