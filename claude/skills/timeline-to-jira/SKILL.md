---
name: timeline-to-jira
description: >
  Convert Xan's AIWS program timeline (xlsx Gantt) into Jira tickets in the SAO
  project — component epics + per-row dated tasks with correct assignees. Use
  when Xan wants to turn a timeline (e.g. "timeline revised vN.xlsx") into Jira
  issues, add a new component, or re-sync dates. Creates real, non-deletable
  issues — confirm scope before each batch.
---

# timeline-to-jira — AIWS timeline → SAO Jira tickets

Codifies the mapping proven on 2026-06-25 (Mini Car Course, SAO-8437 + 21 tasks).
Tickets **cannot be deleted** — verify a test ticket's fields before batching,
and confirm scope with Xan before each component.

## Jira target (woven-dojo)

- Site `woven-dojo.atlassian.net` · cloudId `ecbaa248-3747-4626-befe-7babe1f98b0a`
- Project **SAO** (SA Operations Squad, team-managed / `simplified: true`)
- Master program epic **SAO-7208** ("CD - Automated Driving") — high-level only.

## Hierarchy rules (hard-won)

- Hierarchy is **Epic → Task → Subtask**, but:
  - **Epics cannot be parented to epics.** Each component is its own Epic, a
    *sibling* of SAO-7208, linked via a **"Relates"** issue link (not `parent`).
  - **Subtasks do NOT appear on the Jira timeline/roadmap**, and an issue has
    **one assignee**. So: every timeline row becomes its own **Task** (no
    subtasks), and multi-person rows are **split into one Task per person**.
  - Tasks attach to their component epic via the `parent` field (works for
    Task→Epic in this team-managed project).

## Field mapping

| Concept | Jira field | Notes |
|---|---|---|
| Start date | `customfield_10015` | `YYYY-MM-DD` |
| Due date | `duedate` | `YYYY-MM-DD` |
| Priority | `additional_fields: {"priority":{"name":"Medium"}}` | default Medium |
| Assignee | `assignee_account_id` | see table |
| Parent epic | `parent` | task→epic only |

Create via `mcp__atlassian__createJiraIssue`; link epics via
`mcp__atlassian__createIssueLink` (type `Relates`, inward=component epic,
outward=SAO-7208). Edit dates via `mcp__atlassian__editJiraIssue`.

## Account IDs

| Person | accountId |
|---|---|
| Xan Varcoe | `63c4dfaa176040ff3bd146d5` |
| Lewis Baker | `60f5102fecadb10069c0eda0` |
| Ahmed Magdy (Madi) | `712020:76eb0261-fee2-485a-b4f8-a103286d6f40` |
| Justin Sanders | `712020:4175dc98-9cf6-4ec9-b128-ddd6683caed9` |
| Kenta Tanaka | `712020:cfe0c962-cc7d-4342-bf31-2f21ebac1a33` |
| Yumiko Nozaki | `62e752c6f15eecaf500d2777` |

**Assignment rules:**
- Vendor / TSA / MS1 (non-individual owners) → **Xan** (coordinator; name the
  real owner in the description, e.g. "(Vendor, via Xan)").
- All **Localization** rows (AI Translation, Internal Review) → **Kenta**.
- **TSA reviews** → **Xan** (he triages).
- Otherwise use the sheet's "RESPONSIBLE" owner directly.

## Reading the source xlsx

Timeline lives in `in_tray/` or `resources/strategic/` (e.g.
`timeline revised v7.xlsx`, sheet "AIWS Planning Detailed (v6)"). Parse with
openpyxl. **The per-row dates come from the Gantt bar fills, NOT the in-sheet
column-number notes** (those are stale from an earlier version). Algorithm:
1. Build a column→date map: row 6 has day-of-month; month anchors are on row 5
   (JUL=col11, AUG=15, SEP=20, OCT=24, NOV=28, DEC=33, JAN=37, FEB=41, MAR=45);
   cols 7–10 are June. Year rolls to 2027 from JAN.
2. For each task row, the filled (non-empty `patternType`) cells in cols 7–48
   give start = min filled col's date, end = max filled col's date.
3. Components are the rows in col 3; stage/owner rows are cols 5 (DETAILS) + 6
   (RESPONSIBLE). Load with `data_only=False` to read fill styling.

## The per-component template (21 tasks)

Each course component expands to these rows (split reviews per person). Single-
cell Gantt rows → start=due (1-day bar); multi-week rows keep their span (e.g.
Content Design is intentionally ~2 weeks).

1. Assessment Design (Stage 1) — *design owner*
2–4. Review Assessment Design — one each for the listed reviewers
5. Revise + sign-off (Assessment Design) — *design owner*
6. Content Design (Stage 2) — *design owner* (often multi-week)
7–8. Review Content Design — one per reviewer
9. Revise + sign-off (Content Design) ← Generation gate — *design owner*
10. Generation (Stage 3) — *gen owner*
11. Review generated content — reviewer
12. Revise generated content — gen owner
13. Integration (Stage 4) — *integration owner*
14–16. Review (TSA / internal) — one per reviewer; TSA → Xan
17. Revise (Integration) — integration owner
18. Localization AI Translation → Kenta
19. Localization Post-Editing (Vendor, via Xan) → Xan
20. Localization Internal Review → Kenta
21. Publish to MS1 (via Xan) → Xan (mark HARD DEADLINE in desc)

Owners vary by component — read them from the sheet, don't assume. (RS/AS/CARLA
async courses: design=Xan, gen/integration=Madi or Lewis per sheet. Workshops:
design=Lewis.) Summary format: `<Component> — <Stage> (<reviewer-or-note>)`.
Description: one line of stage purpose + "Owner/Reviewer: X" + "Source: AIWS
timeline revised vN."

## Workshops

Mini-Car Workshop and Real Car Workshop: the sheet notes say "ad hoc design (no
formal Stage 1)", but Xan confirmed 2026-06-25 to **use the timeline steps as-is
for now** — so apply the same template, reading owners from the sheet (design =
Lewis for both).

## Course Launch milestones

Sheet rows ~181–185 — 5 learner-launch milestones (TSA-owned, → Xan), HARD
DEADLINES. Create as Tasks (or under a small "Course Launches" epic). Dates per
sheet: Required Nov 2, Mini-Car Workshop Dec 7, RC workshop Dec 14, Advanced
Jan 11, Real Car Workshop Feb 8 (2027).

## Procedure (per component)

1. Confirm with Xan which component(s) to create.
2. Create the **epic** (no parent), assignee Xan, with start = earliest task,
   due = Publish date; description noting publish deadline + "Related: SAO-7208".
3. `createIssueLink` Relates → SAO-7208.
4. Create the 21 tasks in batches (~10 createJiraIssue calls per message), each
   with `parent` = the new epic, dates from the Gantt, assignee per rules.
5. Spot-check assignees in the responses (displayName), report the epic + task
   keys in a table.

## Components & current state (as of 2026-06-25)

10 components: RS Course 1–3, Mini Car Course, Mini-Car Workshop, AS Course 1–3,
CARLA Simulation Course, Real Car Workshop. **Done:** Mini Car Course (SAO-8437,
21 tasks SAO-8438→8458). **Partial:** RS Course 1 (SAO-8435, only SAO-8436
created — needs the other 20). The live cross-machine state is in the vault's
`Notes/session-handoff.md`; check it for the latest before creating more.

## Don'ts
- Don't create issues without confirming scope (no undo).
- Don't trust the sheet's column-number annotations for dates — use bar fills.
- Don't use subtasks for timeline rows. Don't parent an epic to an epic.
