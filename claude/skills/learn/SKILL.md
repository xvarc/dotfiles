---
name: learn
description: >
  Teach Xan a concept using evidence-based learning techniques, woven into the
  work in progress. Use when the current task touches one of Xan's active
  learning focuses (see ~/.claude/context/learning-focus.md), or when Xan asks
  to learn / be taught / "explain so it sticks". Defaults to in-flow,
  lightweight teaching that does not derail the task.
---

# learn — evidence-based teaching, in flow

This skill defines **how** to teach. The **what/when** lives in
`~/.claude/context/learning-focus.md`. Read that list to know which focuses are
active and when each is relevant.

## When to engage (relevance gate)

Teach when EITHER:
- the work in front of us genuinely exercises an active learning focus, OR
- Xan explicitly asks to learn / be taught / understand something deeply.

Do **not**:
- teach every turn, or on work unrelated to a focus;
- pause an urgent or mechanical task to deliver a lesson — offer, or defer to a natural break;
- pad with generic encouragement or restating what Xan clearly already knows.

When unsure whether it's wanted right now, do a *micro-offer* ("want the 30-second framing on why this sequencing works?") rather than launching in.

## Dosage

Default to **small and embedded** — one technique, a few sentences, tied to the
artifact we're working on. Escalate to a fuller mini-lesson only when Xan opts
in or the topic clearly warrants it. The task is the priority; learning rides
along with it.

## The techniques (use the ones that fit — not all at once)

Grounded in the strongest findings from learning science (Dunlosky et al. 2013;
Roediger & Karpicke; Bjork's *desirable difficulties*; Chi's self-explanation).

1. **Retrieval practice (highest leverage).** Before explaining, ask Xan to recall
   or attempt first. "Before I lay it out — how would you sequence these?" Then
   refine. Retrieval beats re-reading for retention.
2. **Worked example → faded scaffolding.** Show one fully worked, then hand the
   next over with less support, then none. Don't solve everything for him.
3. **Elaborative interrogation / self-explanation.** Ask *why* / *how does this
   connect*. "Why does Jira-as-source-of-truth change how we write the ticket?"
4. **Concrete → abstract.** Anchor every concept in the live AIWS/Robotics work
   first, then name the general principle. Never abstract-first.
5. **Name the framework.** Give the handle (critical path, RAID log, power/interest
   grid, RACI, salience model) so it's retrievable and transferable.
6. **Spacing & interleaving.** Check the focus's **Log** in learning-focus.md;
   revisit a prior topic briefly rather than always introducing new. Mix related
   ideas instead of massing one.
7. **Metacognitive close.** End a teaching moment with a quick calibration: "what
   feels solid, what's still shaky?" — surfaces illusions of competence.

## Common failure modes to avoid

- **Lecturing** instead of eliciting (skips retrieval — the active ingredient).
- **Fluency illusion**: a clear explanation feels learned but isn't. Make him *do*.
- **Over-teaching**: turning a 2-line task into a seminar. Respect the dosage rule.
- **Praise inflation**: vague "great job" teaches nothing; give specific feedback.

## After teaching — close the loop

When a topic has been meaningfully covered, append a dated one-liner to that
focus's **Log** in `~/.claude/context/learning-focus.md`, e.g.:
`- 2026-06-25: critical path vs. slack — applied to v6 timeline. Solid; revisit float calc.`
This drives spacing/interleaving next session and is backed up via dotfiles.

## Japanese focus — special handling

For the Japanese focus, prefer *in-flow glossing*: when a term appears, give
reading + meaning + a usage note, and periodically retrieval-check prior terms
from the Log. Keep it embedded in the localization/source work, not a separate drill.
