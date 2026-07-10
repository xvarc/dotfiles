---
name: goodbye
description: >
  End-of-day session close-out for Xan. Run when Xan says goodbye / "I'm done
  for the day" / "wrapping up" / "closing this session". Captures the current
  session's work state into the git-tracked handoff doc so it survives a switch
  to a different machine, scans for other open sessions across all projects,
  saves anything worth remembering, then auto-commits and pushes.
---

# goodbye — persist session state across machines

The problem this solves: Xan works across **two machines** and runs **multiple
concurrent Claude sessions**. Session transcripts and auto-memory live under
`~/.claude/projects/` which is **local-only** (NOT synced — confirmed: `memory/`
is not symlinked into dotfiles). The only things that cross machines are the
**git-tracked vault** and the **dotfiles repo**. Therefore the handoff doc must
live in the vault, and it is the single source of truth for "where I left off."

Pair skill: [hello](../hello/SKILL.md) reads what this writes.

## What "the vault" means here

The current working directory's git repo (e.g. the AIWS vault at
`/Users/superuser/code/wp-content-development/aiws`). The handoff doc lives at
`Notes/session-handoff.md` within it. If the project has no obvious `Notes/`
dir, put it at repo root as `SESSION-HANDOFF.md` and tell Xan.

## Steps

### 1. Identify this session
- Determine the current session id (the `.jsonl` being written in
  `~/.claude/projects/<slug>/`) and the machine hostname (`hostname -s`).
- Get a timestamp: `date '+%Y-%m-%d %H:%M %Z'`.

### 2. Reconstruct this session's work state
From the conversation so far, write a tight block — NOT a transcript, the
**resumable state**:
- **Thread** — what we were doing, in one line.
- **Next concrete action** — the single most important "do this next". Be
  specific: "create AS Course 1 epic + 21-task set; template proven on Mini Car
  (SAO-8437)" — not "continue Jira work".
- **Open decisions** — anything waiting on Xan, with the options.
- **Key facts produced this session** that aren't yet written down anywhere
  synced (IDs created, field mappings, account IDs). Memory does NOT sync, so
  anything load-bearing goes HERE, in the vault.
- **Uncommitted state** — branch, and what's modified but not pushed.

### 3. Write into the handoff doc (per-session block, no clobbering)
`Notes/session-handoff.md` holds one block per session, keyed by session id.
- If a block with this session id exists, **update it**.
- Otherwise **append** a new block. Never overwrite another session's block.
- Mark blocks `STATUS: open`. When Xan says a thread is finished, set
  `STATUS: done` (keep it — history), don't delete.

Block format:

```markdown
## [open] <thread one-liner>
- **Session:** <session-id-short> · **Machine:** <host> · **Updated:** <timestamp>
- **Next action:** <the one specific next step>
- **Open decisions:** <list, or "none">
- **Key facts:** <IDs / mappings / anything load-bearing not synced elsewhere>
- **Uncommitted:** <branch + what's not pushed, or "clean">
```

### 4. Cross-project scan (safety net)
Other sessions in OTHER project folders can't be read from here, but flag them
so `hello` can remind Xan they exist. Find sessions touched today:

```bash
find ~/.claude/projects -name '*.jsonl' -maxdepth 2 -mtime -1 \
  -exec stat -f '%Sm %N' -t '%H:%M' {} \; | sort
```

Group by project slug. In the handoff doc, maintain a single
`## Cross-project (sessions active today)` section listing each OTHER project
slug + the latest activity time, with the note "pointer only — open that vault
and run /hello there to see detail." Overwrite this section each run (it's a
snapshot, not history).

### 5. Save genuinely durable facts to memory too
If something is durable beyond this work thread (a stable preference, a
project-level constraint), also write it to memory per the memory rules — but
remember memory is machine-local, so the handoff doc remains the cross-machine
carrier. When in doubt, put it in BOTH.

### 6. Auto-commit and push (no prompt)
Per Xan's standing choice, commit and push without asking:

```bash
git -C <vault> add -A && \
git -C <vault> commit -m "goodbye: session handoff $(date '+%Y-%m-%d %H:%M')" && \
git -C <vault> push
```

If on the default branch and the repo's convention is to branch first, follow
that; the AIWS vault commits directly to master (it auto-pushes hourly), so
direct commit is fine here. End commit messages with the Co-Authored-By trailer
if that's the repo convention. Report the result (pushed / nothing to commit /
push failed) plainly.

### 6b. Also push dotfiles if dirty
Skills, agents, settings, and `context/` files (e.g. `learning-focus.md`) live
in `~/dotfiles` (git, remote `github-personal:xvarc/dotfiles`). These are
symlinked into `~/.claude` and only cross machines when dotfiles is pushed. If
this session changed any of them — or if it's just been a while — sync it too:

```bash
if [ -n "$(git -C ~/dotfiles status --porcelain)" ]; then
  git -C ~/dotfiles add -A && \
  git -C ~/dotfiles commit -m "goodbye: sync dotfiles $(date '+%Y-%m-%d %H:%M')" && \
  git -C ~/dotfiles push
else
  git -C ~/dotfiles push   # push any local commits not yet on the remote
fi
```

Caveat to keep stating honestly: this syncs the **config/capability layer**
(skills, agents, settings, context). It does NOT sync auto-memory or session
transcripts — those live in `~/.claude/projects/`, are not in dotfiles, and stay
machine-local. That's exactly why load-bearing facts go in the vault handoff doc
(step 2), not only in memory.

### 7. Send the handoff block to Xan on Slack
Use the `mcp__plugin_slack_slack__slack_send_message` tool to DM the session's
handoff block to Xan (user ID `U04J9QHDDNZ`) so it's waiting on his other
machine when he starts the next session.

Compose the message from the current session's block. Include:
- The thread one-liner as a bold header
- Next action
- The two or three most important open decisions (not the full key-facts dump —
  those are in the vault)

Keep it under ~30 lines — it's a cross-machine nudge, not a transcript.

If the Slack MCP tools are not available (e.g. plugin not authenticated), skip
this step silently and note it in the sign-off text so Xan knows to check the
vault directly.

### 8. Sign off
One-line summary: what was saved, what the next action is, and a reminder of any
OTHER open sessions Xan should close too.

## Don'ts
- Don't delete other sessions' blocks or the cross-project section's history of
  open threads.
- Don't write a transcript — write resumable state.
- Don't claim to have read other live sessions — you can only see file
  timestamps for those, not contents.
