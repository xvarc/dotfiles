---
name: course-sync
description: >
  Sync AIWS course design docs from the vault (source of truth) into riverflow
  and publish a versioned snapshot to the per-course GitLab repo. One-directional:
  vault → riverflow DB → GitLab. Use when a course's scope/assessment design has
  changed in the vault and its GitLab repo needs to catch up, or to onboard a new
  course into version control. Never edits the vault from GitLab; never regenerates
  signed-off stages.
---

# course-sync — vault → riverflow → GitLab, one source of truth

Solves the "two sources of truth" problem **by direction, not by relocation.** The
vault stays authoritative; the per-course GitLab repo is a downstream published
snapshot. This skill makes the flow repeatable so the copies can't silently diverge:
you regenerate the downstream from the vault, you never hand-edit it.

Read the `riverflow` skill first — this skill is a thin, opinionated wrapper over it
and inherits all its traps (import-don't-generate, DB-is-live/GitLab-is-stale, the
scenario-lock fabrication trap for any *generated* content).

## The model (state it, don't drift from it)

| Layer | Role | Who writes it |
|---|---|---|
| **Vault** `design/…` (+ `Notes/`, manifests, register) | **Source of truth.** Authoring, cross-cutting docs, notes, backlinks. | Xan, in Obsidian |
| **Riverflow DB** (stage outputs) | Pipeline working state. Populated **only** by import from the vault. | this skill (`save_stage_output`) |
| **GitLab per-course repo** | Versioned, published deliverable — what TMC/downstream sees, what generation consumes. | this skill (`commit_snapshot`) — **never by hand** |

Flow is **vault → import → snapshot**, never backward. If GitLab and the vault
disagree, the vault wins and you re-run this skill. There is no path where a GitLab
edit flows back into the vault. (If collaborator review ever moves *into* GitLab —
TMC editing design docs there — this model must be revisited; today review is in
Jira + GDrive, so GitLab is publish-only.)

## Course registry

The mapping of vault docs ↔ riverflow courseId ↔ GitLab repo. **Update this table
whenever a course gets a remote repo.** A course with no `courseId` is not yet in
riverflow — create it with `create_course` (versionControl:true) first, then record
the IDs here.

| Course | Vault course folder | riverflow courseId | GitLab repo |
|---|---|---|---|
| RS Course 2 | `design/courses/rs-course-2/` | `cmrka2p6p0000cc4h5gz8m9ui` | `ms1-learner/rs-course-2-cnns-and-transfer-learning-cmrka2` (project 21852) |
| RS Course 1 | `design/courses/rs-course-1/` | _(not yet in riverflow)_ | _(none yet)_ |
| RS Course 3 | `design/courses/rs-course-3/` | _(not yet in riverflow)_ | _(none yet)_ |
| Mini Car Course | `design/courses/mini-car-course/` | _(not yet in riverflow)_ | _(none yet)_ |
| Mini-Car Workshop | `design/courses/mini-car-workshop/` | _(not yet in riverflow)_ | _(none yet)_ |
| AS Course 1/2/3 | `design/courses/as-course-{1,2,3}/` | _(not yet in riverflow)_ | _(none yet)_ |
| CARLA Simulation Course | `design/courses/carla-simulation-course/` | _(not yet in riverflow)_ | _(none yet)_ |
| Real Car Workshop | `design/courses/real-car-workshop/` | _(not yet in riverflow)_ | _(none yet)_ |
| Track Introduction | `design/courses/track-introduction/` | _(not yet in riverflow)_ | _(none yet)_ |

Within a course folder: `scope/scope.md`, `assessment/assessment-design.md` (+ `run-log.md`,
`reviews/`), `content-design/`, `source/` (per-course source manifest, e.g. RS2's
`source/source-manifest.md` → imported to `content-design/llmContext`). Cross-cutting
docs (program manifest, hardware register, templates, scope-change-log, source-notes)
live in `design/shared/` — see CLAUDE.md's vault layout table for the full map.
Vault reorganized to this course-centric layout 2026-07-14 (was stage-centric:
`design/scope/docs/`, `design/assessment-design/`, `design/program/`, `design/source/`,
`design/workshops/`).

## Slot mapping — how one AD file splits across riverflow slots

The vault AD is one markdown file; riverflow stores it in typed slots. Split by
section (the AD headings are stable across RS-track courses):

| Riverflow slot | Vault source | What goes in |
|---|---|---|
| `scope` / `scope` | the scope doc | whole file |
| `assessment` / `project` | AD | Project Description + rubric (+ a short source-taxonomy note if the course has one) |
| `assessment` / `challenges` | AD | Units and Challenges + Extensions + LO Mapping Matrix + Challenge Dependency Graph |
| `content-design` / `llmContext` | source manifest | whole file (grounding layer, if one exists) |

Sections the vault AD carries that have **no riverflow slot** (Compute Constraints,
Assumptions, Open items, Reference, Persona, Solutions) stay vault-only. That's
expected — GitLab publishes the deliverable projection, not the working doc. Do not
invent slots for them.

## Procedure

For each course being synced:

1. **Confirm the registry row.** If the course has no `courseId`, `create_course(title, versionControl:true)` and record the returned `courseId` + repo in the table above. (`versionControl:true` also pushes the first snapshot.)
2. **Read the vault docs** (scope, AD, manifest). These are authoritative — do not modify them.
3. **Import each slot** with `save_stage_output(courseId, stage, key, content)` per the slot-mapping table. Splitting the AD is a read-and-section task — keep section text verbatim, don't paraphrase. Every imported output should come back `isEdited: true`.
4. **Never `generate_stage` / `generate_lesson_plan`** on signed-off design. This skill only imports. (Downstream *content* generation is a separate, later, human-owned step — see the riverflow skill.)
5. **Confirm with Xan before committing** if this is a publish to a repo TMC can see — the GitLab repo is the outward-facing copy. A routine catch-up after vault edits Xan just made needs no re-confirmation.
6. **`commit_snapshot(courseId, message)`** with a message that names what changed and cites the vault commit (e.g. `RS2 AD rev.2 — source taxonomy fix (vault synced <shortsha>)`). This is the step that makes GitLab match the DB — skipping it leaves GitLab stale (riverflow Trap 6).
7. **Report**: courseId, repo URL, commit id, and which slots were updated.

## Guardrails

- **Vault is never written from here.** This skill reads the vault and writes riverflow/GitLab only. (Vault write-safety rules still apply to any *other* edit.)
- **GitLab is regenerated, not edited.** If someone hand-edited the GitLab repo, that edit is not authoritative and will be overwritten on next sync — flag it to Xan rather than preserving it.
- **DB is live; GitLab is a snapshot.** After any import you must `commit_snapshot` or GitLab lies. Conversely, `get_version_status` showing an old commit means "un-synced imports exist," not "nothing changed."
- **Known-blocked in this environment** (see `reference_riverflow_vc_config` memory): `check_conformance`/`apply_conformance_fix` (Bedrock 401) and playbook clone (token scope). Neither blocks import or commit. Don't burn time retrying them; note them and move on.
- **Secrets:** the GitLab token lives only in riverflow's gitignored `.env` (outside the vault). Never write it into a vault-tracked file — the vault auto-pushes.
- **Server `.env` reload:** if VC reports `configured:false`, the riverflow server needs a restart to reload `.env` (see the memory). Restart, don't debug in circles.
