---
name: riverflow
description: >
  Operating manual for the riverflow MCP course-authoring tool, used the way the
  AIWS program actually needs it: forward design from an already-signed-off
  scope + assessment design, with a source-grounded anti-hallucination layer.
  Invoke whenever working with riverflow (`mcp__riverflow__*` tools) — creating a
  course, importing an AD, generating content-design stages, running lesson/unit
  generation, version control, or exporting a deliverable for review. Riverflow is
  built for greenfield generate-from-scratch; the AIWS pipeline uses it in an
  import-first, human-designed-upstream way it was not built for, so this skill
  supplies the missing context.
---

# riverflow — forward-design operating manual

Riverflow is an MCP-connected course-authoring pipeline (Stage 0 scope → Stage 1
assessment → Stage 2 content-design → Stage 3 generation) backed by a database,
with optional GitLab version control. It is **built for greenfield generation**:
fill a scope form, let the model generate each stage from the previous one.

**The AIWS program does NOT use it that way.** In AIWS, the scope doc and
assessment design are authored and signed off *by hand, upstream*, grounded in
real TMC source material, with an anti-hallucination discipline. Riverflow is
used to **hold that human-designed work and drive the downstream content-design
structure from it** — import-first, not generate-first. This skill exists because
that mode is not what the tool's affordances assume, and the gaps are non-obvious.

Read this before touching `mcp__riverflow__*` tools. The traps below were each
learned the hard way.

---

## The golden rule: import, don't regenerate

The signed-off scope + assessment design are the **source of truth** and were
grounded in real source material. Riverflow's generators do NOT have that source.
So:

- **Import** the human-authored scope and assessment via `save_stage_output` — do
  NOT `generate_stage scope` / regenerate the assessment. Generation will
  fabricate or drift from the signed-off design.
- **Generate** only the downstream *structural* stages (content-design) that
  legitimately derive from the imported design — then **diff every one against the
  source** before trusting it.

Precedent: a course whose stage outputs show `isEdited: true` was imported, not
generated. That is the pattern to follow.

---

## Trap 1 — `set_scope_form` is NOT read by the generators

`set_scope_form` populates riverflow's **web create-flow form**. The generation
prompts do **not** read `scopeFormData`. Proof: after setting a full scope form,
`generate_stage scope` produced "no skills / no sources provided" and defaulted
the persona to a placeholder.

**Consequence:** setting the scope form is near-useless for generation. What the
generators actually consume is the **`scope` stage output** and the **`llmContext`
stage output**. Import real markdown into those via `save_stage_output`:

```
save_stage_output(courseId, stage="scope",          key="scope",      content=<real scope md>)
save_stage_output(courseId, stage="content-design", key="llmContext", content=<grounding md>)
```

---

## Trap 2 — stage/key names are specific and pipeline-gated

`generate_stage <x>` will 400 with "`<A>` and `<B>` are required" if an upstream
output it reads is missing. The real dependency chain (not obvious from tool defs):

- `structure` (content-design) requires a **`scope`/`scope`** output present. If
  you only set the scope *form*, it fails — import the scope stage output first.
- `llm-context` requires **lesson plans to exist** (`lessonPlansOutput`).
- `generate_unit` requires **lesson plans** for that unit.

So the working order for forward design is:

1. `create_course`
2. `save_stage_output scope/scope` ← import real scope md
3. `save_stage_output assessment/{project, projectScope, challenges, challengeDescriptions}` ← import AD
4. `save_stage_output content-design/llmContext` ← import the grounding layer (see below)
5. `generate_stage structure`  → diff
6. `generate_stage lesson-types` → diff
7. `generate_stage assessment-details` → diff
8. page stages if wanted: `project-page`, `challenge-pages`, `orientation`, `conclusion` (these land under the **`generation`** stage, key e.g. `projectPage`)
9. `generate_lesson_plan` per lesson → diff + fix each
10. (Stage 3, usually a different owner) `generate_unit` per unit

**Known stage/key map observed in practice:**
| Stage | Keys |
|---|---|
| `scope` | `scope` |
| `assessment` | `project`, `projectScope`, `challenges`, `challengeDescriptions` |
| `content-design` | `structure`, `lessonTypes`, `assessmentDetails`, `llmContext`, `lessonPlans` |
| `generation` | `projectPage`, and page/unit outputs |

`get_stage_output(courseId, stage, key)` reads one; `get_course(courseId)` returns
all outputs (as JSON — large; each output has an `isEdited` flag telling you
imported/hand-edited vs generated).

---

## Trap 3 — the anti-hallucination grounding layer (`llmContext`)

The generators only see what you import. For a source-grounded course you MUST
build and import a **pinned-fact manifest** into `content-design/llmContext`
before any per-lesson generation, or the model invents hyperparameters, filenames,
ports, and API calls.

Structure the `llmContext` (mirror the RS1 manifest precedent):
- **SCENARIO LOCK** (see Trap 4) — first, emphatic.
- **Structure facts** (source-of-truth: length, units, LOs, persona, rubric model).
- **CONFIRMED facts** — verbatim, safe to assert, each traceable to a read source
  file (exact constant names, ports, class names, file layouts, API attributes).
- **OPEN / UNVERIFIED** — do NOT assert; flag or defer (e.g. unverified model
  internals, unproven sim paths, value discrepancies across sources).
- **CREDENTIAL HYGIENE** — secrets that must never appear in learner content.
- **FRAMING CONSTRAINTS** — naming rules, rights limits, what's out of scope.

Then diff every generated lesson's technical values against this manifest. In
practice the CONFIRMED facts held reliably; the model respected OPEN flags (left
values unstated rather than inventing). Also keep the manifest as a durable vault
file, not only in riverflow.

---

## Trap 4 — the generator fabricates a fictional company every lesson

`generate_lesson_plan` reliably invents a **different** fictional company/domain
per lesson (observed: "Kaimen Robotics / Rindo Robotics / LapLine Robotics /
Rittai Robotics / Keisen Vision" — warehouse rovers, floor cleaners, etc.),
**regardless of an explicit scenario-lock instruction in `llmContext`.** Technical
grounding is honoured; scenario framing is treated as free creative latitude.

**Consequence:** scenario correction is a **mandatory deterministic post-fix on
every generated lesson.** Do not trust the prompt to hold it. After generating
each lesson, replace its Scenario Context block with the real course scenario.
`generate_lesson_plan` **appends** to the `lessonPlans` output, so fixing means
re-saving the whole accumulated `lessonPlans` via `save_stage_output` (to avoid
re-sending the growing doc many times, you can generate several then do one
consolidated fixed save — but still diff each individually as it lands).

---

## Trap 5 — generated content drifts from the signed-off design; always diff

Even with grounding, generated stages drift. Observed and corrected this session:
- Renamed the course (appended a subtitle) — reverted.
- Reintroduced numeric rubric scoring ("Total 10 points", "0–2 each",
  "Does Not Meet / Meets / Exceeds") when the design is a **non-scored 3-column
  Not Met / Partially Met / Fully Met** rubric — stripped everywhere.
- Conflated two different annotation tasks across criteria.
- Swapped a corrected API attribute back to the wrong one.

**Discipline:** every generated stage gets diffed against the AD + manifest before
it's trusted. Fixes go back via `save_stage_output` to the same stage/key.

---

## Version control (GitLab)

Optional, server-gated. `init_version_control` → creates a per-course GitLab repo
and pushes a snapshot. `commit_snapshot` → commits current state. `cut_release` →
tags. `get_version_status` → status. `compare_versions` → diff refs.

**Server config (AIWS/riverflow instance):** riverflow runs locally at
`/Users/xan.varcoe/code/wp-work/riverflow`; the API server is `tsx server/index.ts`
on port **3002** (the MCP process `mcp/server.ts` is separate). Config lives in
`.env` (gitignored), loaded via `dotenv.config()` **at startup only**.

- GitLab is gated purely on `GITLAB_API_TOKEN` (`isGitlabConfigured()` = `!!token`).
- `GITLAB_COURSES_NAMESPACE` is **required in practice**: the token is a **group
  bot** (`riverflow-api`, group `ms1-learner`, id 11) whose personal namespace
  can't hold real projects. Set `GITLAB_COURSES_NAMESPACE=ms1-learner`. Empty →
  GitLab 400 `namespace: is not valid`.
- `GITLAB_HOST=https://git.ms1.com`, `GITLAB_VISIBILITY=internal`.

**After editing `.env`, the server must be restarted to reload it:**
```
pkill -f "tsx server/index.ts"; sleep 2
cd /Users/xan.varcoe/code/wp-work/riverflow && nohup npm run server > /tmp/riverflow-server.log 2>&1 &
```
Then `get_version_status` should show `configured: true`.

**Repo layout riverflow pushes** (this IS the playbook deliverable format — see
below): `design/{project_scope,assessment_design,content_design,content_design_llm}.md`,
`content/en/lesson_plans/unit*.md`, `content/en/challenges/challenge*/challenge.md`,
`content/en/project/project.md`, `content/en/units/*.md`, `course.json`.

---

## Trap 6 — the GitLab snapshot goes stale; the DB is the live copy

`init_version_control` pushes a snapshot **at that moment**. Every later
`save_stage_output` / `generate_stage` writes to the **database**, NOT to GitLab.
So after fixes, the GitLab repo is stale until you `commit_snapshot` again.

**When someone asks "is it backed up in GitLab?" the honest answer is: only the
state at last snapshot/commit.** Re-commit after a round of fixes so GitLab matches
the DB.

---

## Deliverable format for review — use riverflow's files, not a hand-assembly

Riverflow produces the **playbook-format** deliverable files itself:
- `design/project_scope.md` — Stage 0/1 scope
- `design/assessment_design.md` — assessment
- `design/content_design.md` — **the content-design deliverable**, already bundling
  Skill Decomposition, Course Structure, Course Overview, Unit Goals, Glossary,
  Lesson Types, and Assessment Details (Project + Challenge). This is the
  playbook shape.
- `design/content_design_llm.md` — the grounding/llm-context
- `content/en/lesson_plans/unit*.md` — the lesson plans, one file each

**Do NOT hand-assemble your own consolidated doc and present it as the deliverable.**
It won't match the playbook structure and it won't be version-controlled. If a
single-scroll copy is wanted for Google Docs, generate it FROM the riverflow files
and label it clearly as a convenience copy, and make sure riverflow's DB has been
committed to GitLab first so the source is current.

To get review-ready current files: `commit_snapshot` (so GitLab = DB), then pull
`design/content_design.md` (+ lesson plans) from the repo, or read them via
`get_stage_output`.

**Open design questions belong in the content-design deliverable** — reviewers need
to see what's unresolved. Fold the manifest's OPEN/UNVERIFIED items plus any
content-design-relevant open items into the deliverable (grouped: blocking-generation
/ values-to-pin / reviewer-decisions / rights-compliance), each with what's open,
what closes it, and the owner.

---

## Stage ownership (AIWS)

- **Stage 0–2 (scope, assessment, content design):** Xan (CM + design).
- **Stage 3 (generation — `generate_unit`: concept prose, worked exercises, unit
  quizzes):** Madi (ID). Do NOT run `generate_unit` on Xan's behalf without an
  explicit ask — it's her stage. Xan reviews her output.
- Content Design is "done" when structure + lesson-types + assessment-details +
  all lesson plans + grounding layer are complete and diffed. Unit content is NOT
  part of the content-design deliverable.

---

## Quick reference — tool call cheatsheet

- Discover: `list_courses`, `get_course`, `get_stage_output`, `get_playbook_status`
- Import/edit: `save_stage_output(courseId, stage, key, content)`
- Generate (diff after each): `generate_stage(courseId, stage)`,
  `generate_lesson_plan(courseId, lessonId)`, `generate_unit(courseId, unitId)`
- Scope form (rarely useful for generation — see Trap 1): `set_scope_form`
- VC: `init_version_control`, `commit_snapshot`, `cut_release`,
  `get_version_status`, `compare_versions`
- Models: `list_models`, `set_model`

Course IDs look like `cmreml...`. Always pass the exact `courseId`.

---

## Session-proven workflow summary

1. `create_course`.
2. Import scope + AD via `save_stage_output` (Trap 1, 2). Never regenerate them.
3. Build + import the `llmContext` grounding manifest from real source notes
   (Trap 3). Keep a durable vault copy too.
4. `generate_stage structure` → `lesson-types` → `assessment-details`; diff each
   against AD + manifest; fix via `save_stage_output` (Trap 5).
5. `generate_lesson_plan` per lesson; diff technical facts (should hold) and
   **always fix the fabricated scenario** (Trap 4).
6. Keep the rubric non-scored 3-column everywhere; strip any numeric scoring the
   generator reintroduces (Trap 5).
7. For VC: ensure `.env` has token + namespace, restart server, `init_version_control`,
   and `commit_snapshot` after each fix round so GitLab isn't stale (Trap 6).
8. For review, hand over riverflow's `design/content_design.md` + lesson plans
   (playbook format), current, with open questions folded in — not a hand-assembly.
