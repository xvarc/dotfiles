---
name: morning-report
description: >
  Draft a morning standup report in Xan's voice, ready to paste into Slack.
  Run when Xan says "morning report", "standup bullets", or "what do I report
  today" on a day he has to give a status update. Pulls current project state
  via chief-of-staff, then compresses it into a few voice-matched bullets —
  drafts only, never sends.
---

# morning-report — standup bullets in Xan's voice

Two-step pipeline: **state → voice**. This skill does not decide what's true
(that's chief-of-staff's job) and does not post anywhere (draft only, Xan
sends it himself). Counterpart to [hello](../hello/SKILL.md) — `hello` is
full session orientation across every open thread; this is a narrow "what do
I say out loud today" extract for the one project Xan is reporting on.

## Steps

### 1. Confirm scope if ambiguous
If Xan hasn't said which project/program this report is for and the working
directory isn't obviously the one program he reports on daily, ask. Don't
guess across multiple vaults.

### 2. Get current state
Invoke the **chief-of-staff** agent for that project. Use its briefing as-is
— don't re-derive state yourself, don't second-guess its read of the tracking
docs.

### 3. Compress to report-worthy bullets
A standup report is not the full chief-of-staff briefing. Cut it down to what
a stakeholder actually needs to hear:
- Prioritize: overdue or due-today items > blockers needing someone else's
  action > yesterday's completed work > everything else.
- Drop internal-only detail (nothing flagged internal-only in frontmatter,
  nothing from `Notes/archive/`).
- Aim for 3–6 bullets. If chief-of-staff surfaces more than that, pick the
  ones with the nearest deadline or highest blast radius — say what got cut
  and why, don't silently drop it.

### 4. Draft in Xan's voice
Apply the **xan-voice** skill, Gear 2 (professional async — this is a
stakeholder-facing status update, not casual chat). Output format:

```
- <bullet>
- <bullet>
- <bullet>
```

No preamble, no "here's your report" framing — just the bullets, ready to
paste directly into Slack.

### 5. Hand back, don't send
Present the bullets and stop. This skill never posts to Slack or anywhere
else on its own — Xan reviews and sends manually. If Xan later asks to
automate delivery, that's a separate, explicit decision (channel + cadence
+ trial period) — don't fold it into this skill silently.

## Notes
- If chief-of-staff can't find tracking docs or flags heavy staleness, say so
  in the handback rather than drafting confident-sounding bullets from thin
  state.
- Don't reuse yesterday's bullets verbatim — re-pull state every time this
  runs, even if it feels unchanged.
