---
name: aiws-nudge
description: >
  Draft an AIWS Jira review/deadline nudge for Slack, in Xan's voice. Run when
  Xan says "aiws nudge", "nudge the team", "who's due", or on the scheduled
  cadence (Tue morning, Thu afternoon). Sweeps all AIWS epics for overdue and
  soon-due tickets, excludes Xan's own items from the nudge, and drafts a
  weekend-aware Slack message copied to the clipboard for confirmation before
  posting. On Monday start-of-day it switches to a missed-deadline report.
---

# aiws-nudge — AIWS review/deadline nudge in Xan's voice

Keeps the AIWS review pipeline moving by nudging the people who owe reviews or
drafts, before their deadlines slip. **State → voice → clipboard.** This skill
finds what's due (from Jira, live — never a hard-coded ticket list), drafts the
nudge in Xan's voice, and copies it to the clipboard. Xan confirms and posts.

Counterpart to [morning-report](../morning-report/SKILL.md) (standup bullets)
and [friday-report](../friday-report/SKILL.md) (weekly report). This one is
narrow: "who do I need to chase, and what do I say."

---

## Fixed anchors (verify before relying — Jira IDs drift)

- **Jira site:** `woven-dojo.atlassian.net` · **cloudId** `ecbaa248-3747-4626-befe-7babe1f98b0a` · project **SAO** (team-managed).
- **Use the `atlassian` MCP server** (Atlassian Cloud), NOT `jira-mcp` — that one is pointed at `jira.tmc-stargate.com`, a different instance where project "SAO" does not exist.
- **The 10 AIWS component epics** (sweep all of them):
  | Epic | Component |
  |---|---|
  | SAO-8435 | RS Course 1 |
  | SAO-8523 | RS Course 2 |
  | SAO-8552 | RS Course 3 |
  | SAO-8553 | AS Course 1 |
  | SAO-8554 | AS Course 2 |
  | SAO-8555 | AS Course 3 |
  | SAO-8437 | Mini Car Course |
  | SAO-8459 | Mini-Car Workshop |
  | SAO-8556 | CARLA Simulation Course |
  | SAO-8557 | Real Car Workshop |
- **Slack channel:** `#temp-ms1-tsa-aiws-dev` = `C0ASUCPLPKN` (the active TSA/dev channel — NOT `#aiws-workshop` C0AJU0S24VB, which is the dead March cohort-logistics channel).
- **Slack member IDs** (for `<@ID>` mentions that always resolve on paste): Justin `U07NQAXB9N2` · Lewis `U016DBFCNSD` · Madi `U04L7BAH4NA` · Xan `U04J9QHDDNZ` · Kenta `U06QRC933EZ`.
- **Xan's Jira account:** display name "Xan Varcoe (Woven Planet)", accountId `63c4dfaa176040ff3bd146d5`. **Never nudge Xan** — his items go in the "on my side" closing line instead.

---

## Steps

### 1. Decide the mode
- **Monday (start of day):** run **missed-deadline report** mode (Step 5). Report what slipped over the weekend; don't nudge.
- **Any other day (incl. the Tue AM / Thu PM cadence):** run **nudge** mode (Steps 2–4).

If Xan invoked it explicitly and the intent is ambiguous, default to nudge mode.

### 2. Sweep all AIWS epics (live — never hard-code the ticket list)
Query Jira for every non-Done task under the 10 epics that is overdue or due
through the end of the coming weekend. Use `searchJiraIssuesUsingJql`:

```
project = SAO
AND parent in (SAO-8435,SAO-8523,SAO-8552,SAO-8437,SAO-8459,SAO-8553,SAO-8554,SAO-8555,SAO-8556,SAO-8557)
AND statusCategory != Done
AND duedate <= "<END-OF-WEEKEND>"
ORDER BY duedate ASC
```

Fields to request: `summary,status,assignee,duedate,parent`. The JQL output is
large — save and parse with `jq` rather than reading inline:
`jq -r '.issues.nodes[] | [.key, .fields.duedate, .fields.status.name, (.fields.assignee.displayName // "UNASSIGNED"), .fields.parent.key, .fields.summary] | @tsv'`

**Weekend-aware deadline framing.** A due date that falls Fri/Sat/Sun should be
swept as due through that weekend — Xan's steer: "by Friday" in his head often
means "by the end of the weekend," so `<END-OF-WEEKEND>` = the coming Sunday's
date. (Dates are unavailable in-script — get today's date from the environment
context or ask, then compute the Sunday.)

BUT never phrase the nudge in a way that implies people should work over the
weekend. Do NOT write "stay on track through the weekend", "by Sunday", "over
the weekend", or anything that reads as expecting weekend work. Instead frame
soft, respecting-time deadlines: "before you finish up this week", "by early
next week", "start of next week is fine". The internal goal (Sunday cutoff) can
be met by Monday-morning framing without pressuring anyone's Saturday. When in
doubt, state the review is ready and ask for it "by the start of next week."

### 3. Triage — who actually gets nudged
- **Exclude Xan's own tickets** from the nudge body. They belong in the closing
  "on my side" line (Step 4), stated as commitments, not chases.
- **Split into two buckets:** *Due this weekend* and *Already overdue*.
- **Flag dependencies:** if a review ticket is due but the draft it reviews is
  itself incomplete, say which one blocks the others.
- **Do NOT trust Jira status blindly.** Status often lags reality (e.g. a draft
  Lewis has finished may still read "To Do"; a review Xan has done may be open).
  Before asserting something is overdue or incomplete, sanity-check against the
  session-handoff doc and what Xan has said this session, and **ask Xan to
  confirm anything that looks stale** rather than nudging someone for work
  they've already done. A wrong nudge costs credibility.
- **Unassigned tickets** can't be nudged at a person — surface them separately
  as "due + needs an owner."

### 4. Draft the nudge (Xan's voice, Gear 2) and copy to clipboard
Invoke the voice spec via `/xan-voice` if not already loaded. Gear 2
(professional async Slack). Shape:

- One-line opener, gentle, may carry a single softening `:)`. No apologising for bumping.
- **Due by Sunday (<date>):** bullet per person/ticket, with the SAO-key(s).
- **Already overdue — good to close this week:** bullet per person/ticket.
- An explicit invitation to re-plan if dates no longer work (forward-looking,
  invites disagreement — a Xan hallmark).
- Closing **"On my side:"** line = Xan's own commitments (RS2, sign-offs, etc.),
  from Jira + what he's told you this session.

**Mentions:** put `@Name` before each person so Slack can resolve them. If Xan
wants guaranteed resolution on paste, use the `<@MEMBER_ID>` form from the
anchors above instead.

**Always copy the final text to the clipboard** with `pbcopy` (heredoc, so
formatting survives), and also show it in the reply. Confirm the line count.

**Delivery discipline:** for now, **draft-only** — show it and copy it, let Xan
post. Once Xan says he's comfortable, this skill may post directly to
`C0ASUCPLPKN` via `slack_send_message`. Until then, never auto-send.

### 5. Monday missed-deadline report mode
Same sweep (Step 2), but `duedate < today AND statusCategory != Done`. Report,
don't nudge:
- List each slipped ticket: key, component, owner, how many days over, status.
- Call out which are Xan's own vs others'.
- Flag any that block downstream work.
- Offer to turn it into a nudge (Steps 3–4) if Xan wants to chase.

Keep it a plain briefing to Xan (not voiced for Slack) unless he asks to send it.

---

### 6. Clear the pending marker
After drafting (nudge mode) or reporting (Monday mode), clear any matching
marker so `hello` / `chief-of-staff` stop reminding about it:

```bash
rm -f ~/.claude/aiws-nudge/pending/*.flag
```

(Clear all flags — if Xan is running the nudge, any pending trigger is now
handled. Leave the `scheduler.log` and `launchd.*.log` files.)

## Scheduling
Runs on a schedule via **macOS launchd** (robust — survives restarts, fires
without a Claude session open): **Tuesday 08:57** and **Thursday 14:03** nudges,
plus the **Monday 08:57** missed-deadline check.

launchd does NOT run the nudge itself (the nudge is draft-first and needs an
interactive session for MCP auth + Xan's confirmation). Instead it runs
`scheduler/drop-marker.sh <kind>`, which drops a marker file in
`~/.claude/aiws-nudge/pending/`. `hello` and `chief-of-staff` read those markers
and remind Xan a nudge is due (or was missed, if the marker is stale). Xan then
runs `/aiws-nudge` interactively.

- Plists: `~/Library/LaunchAgents/com.xan.aiws-nudge.{tue,thu,mon}.plist`
- Trigger script: `scheduler/drop-marker.sh` (in this skill dir)
- Markers + logs: `~/.claude/aiws-nudge/pending/` (machine-local, not in the vault)

The plists live outside dotfiles (in `~/Library/LaunchAgents`), so **on a new
machine they must be recreated and bootstrapped** — the skill and its
`scheduler/` script travel via dotfiles, but the launchd registration does not.
To (re)load: `launchctl bootstrap gui/$(id -u) <plist>` for each.

If the schedule fires and there's nothing due, say so briefly rather than
manufacturing a nudge.

## Notes
- Never nudge Xan. His items are commitments in the closing line.
- Live data only — sweep the epics every run; don't reuse a stale ticket list.
- Draft-first until Xan promotes it to auto-send.
- Verify Jira IDs still resolve — epics and account IDs can change.
