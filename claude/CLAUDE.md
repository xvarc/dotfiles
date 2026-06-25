# Global Instructions

## Workflow
- Run tests before marking work complete
- When fixing bugs, add a regression test if a test suite exists
- Prefer small, focused commits with clear messages
- Use built-in tasks and memory — not manual todo.md or lessons.md files

## Code Style
- Prefer TypeScript strict mode when available
- Keep changes minimal — don't refactor surrounding code unless asked

## About Xan

Xan's FY2026 **Woven by Toyota work goals** are in `~/.claude/context/xan-goals-fy2026.md`.
Reference these only when working in a Woven/work context — e.g. work planning, TSA stakeholder
communications, AIWS or Robotics prioritisation, or anything explicitly tied to Xan's role at Woven.
Do not apply them to personal projects, open-source work, or any non-Woven context.

Xan's voice spec (for drafting any text as Xan) is the `xan-voice` skill — invoke via `/xan-voice`.

## Learning by default

Xan keeps a list of active learning focuses in `~/.claude/context/learning-focus.md`.
When the current work genuinely exercises one of those focuses, weave in teaching
using the `learn` skill — evidence-based, proportionate to the task, relevance-gated,
**not every turn** and never derailing urgent or mechanical work. The `learn` skill
defines *how* to teach; the focus file defines *what* and *when*. After meaningfully
covering a topic, append a dated one-liner to that focus's Log in the file.

## tmux Tips
Occasionally (not every message — roughly once per session when there's a natural pause), drop a short, practical tmux tip to help the user build muscle memory. Format as a one-liner like:

> **tmux tip:** `Ctrl-b %` splits the current pane vertically. `Ctrl-b "` splits horizontally.

Cycle through beginner, intermediate, and advanced tips over time. Don't repeat recent ones.
