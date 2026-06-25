---
name: hello
description: >
  Start-of-day orientation for Xan. Run when Xan says hello / "good morning" /
  "where did I leave off" / "what's on today" at the start of a work session.
  Pulls the latest vault state, reads the cross-machine handoff doc, shows the
  board of open work threads with their next actions, flags other open sessions,
  then runs the chief-of-staff brief for live program state.
---

# hello — orient at the start of the day

Counterpart to [goodbye](../goodbye/SKILL.md). `goodbye` persists session state
into the git-tracked handoff doc; `hello` reads it back — crucially, after a
possible switch to a **different machine**. Session transcripts and memory are
local-only, so the handoff doc in the vault is the only thing that crossed over.

## Steps

### 1. Pull first (get the other machine's handoff)
The handoff may have been written on a different computer. Before reading
anything, sync the vault:

```bash
git -C <vault> pull --no-edit
```

If the pull conflicts or fails, surface it immediately — don't proceed on stale
state. The vault auto-pushes hourly, so conflicts are rare but possible.

Also pull **dotfiles** — skills, agents, settings, and `context/` files may have
been updated (e.g. by `goodbye`) on the other machine:

```bash
git -C ~/dotfiles pull --no-edit
```

If dotfiles changed, note it (skills/config may have updated this session). Then
remind Xan that **memory does not travel** — anything load-bearing from the
other machine should be in the vault handoff doc, which is what we read next.

### 2. Read the handoff doc
Open `Notes/session-handoff.md` (or `SESSION-HANDOFF.md` at root). Parse the
per-session blocks.
- Collect all `STATUS: open` threads.
- Note their **next action** and any **open decisions** — these are the point.
- Read the `Cross-project (sessions active today)` section.

### 3. Present the board
Give Xan a compact orientation, newest/most-relevant first:

```
Welcome back. Here's where things stand:

OPEN THREADS (this vault)
  1. <thread> — next: <next action>   [machine, when]
     open decision: <if any>
  2. ...

⚠ ALSO OPEN ELSEWHERE (other vaults, today)
  - <project-slug> (last active HH:MM) — open that vault + run /hello there
```

If a thread's "last updated" machine differs from the current `hostname -s`,
say so explicitly ("you left this on <other-machine> yesterday") — that's the
cross-machine handoff working.

### 4. Run the chief-of-staff brief
The handoff doc is *your* working state; chief-of-staff is *program* state
(what's due, blocked, drifting per the live tracking docs). Invoke the
**chief-of-staff** agent for the current standup, and fold its output in below
the board so Xan gets both: "where I left my tools" + "what the program needs".

### 5. Hand off to work
Close with a single recommended next step and a question, e.g.:
"Top of the list is finishing the Jira build-out — next action is AS Course 1's
epic + 21 tasks. Want me to start there, or pick up something else?"

## Notes
- Don't mark threads done here — that's for `goodbye` or explicit instruction.
- If the handoff doc doesn't exist yet, say so and offer to start the practice
  (it gets created on the first `goodbye`).
- Keep it tight. This is orientation, not a re-read of everything.
