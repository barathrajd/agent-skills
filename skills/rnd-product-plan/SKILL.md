---
name: rnd-product-plan
description: Turns a rough idea into a researched, decision-complete product plan. Grills the user one question at a time, resolves R&D unknowns with small spikes, and writes a durable PLAN.md with objectives, scope, milestones, risks, and open questions. Use at the start of any new product, feature, or significant change, or when the user says "plan this", "spec this", "grill me", or "figure out what to build".
---

# R&D + Product Plan

## Overview
Produce a plan good enough that the `run-the-plan` skill can build from it without guessing. The output is a single `PLAN.md` file in the repo. The job is not to write code — it is to remove ambiguity and surface the decisions and unknowns that would otherwise blow up mid-build.

Two modes run in sequence:
1. **Grill** — interrogate the idea until intent is clear (~95% confidence).
2. **R&D** — resolve technical unknowns with the smallest experiment that settles each one.

## When to Use
- Starting a new product, feature, or non-trivial change.
- The ask is vague, large, or has unstated assumptions.
- The user says "plan", "spec", "scope", "grill me", or "what should we build".

## Process

### 1. Grill the idea — one question at a time
Ask a single question, wait for the answer, then ask the next. Never dump a list.
- Prefer reading the codebase or existing docs over asking a question you can answer yourself.
- Walk each branch to the bottom before moving on: who is this for, what problem, what does success look like, what is explicitly out of scope, what must NOT change.
- Push back when an answer conflicts with an earlier one. Name the conflict and resolve it before continuing.
- **Exit criterion:** you can restate the goal, the user, and the boundaries in three sentences and the user confirms them.

### 2. Separate the knowns from the unknowns
Write two lists: **Decided** (settled facts) and **Unknown** (anything that would change the design if the answer flipped). Only unknowns justify R&D.

### 3. Run R&D on each unknown — smallest spike that settles it
For each unknown, pick the cheapest way to get a real answer: read the official docs and cite them, check an existing pattern in the repo, or write a throwaway spike you then delete.
- Ground framework/library decisions in primary sources, not memory. If you can't verify a claim, mark it **UNVERIFIED** in the plan rather than asserting it.
- A spike answers one question and is deleted — it is not the start of the implementation.
- **Exit criterion:** every unknown is now either Decided or flagged as a named risk with a fallback.

### 4. Write PLAN.md
Keep it tight. Use these sections exactly:
- **Objective** — one paragraph: the problem and who it's for.
- **Success criteria** — bullet list, each one observable/testable.
- **In scope / Out of scope** — two lists. Out of scope is as important as in.
- **Approach** — the chosen design in a few sentences, plus the key decisions and why (link sources for anything researched).
- **Milestones** — ordered, each a thin end-to-end slice that delivers something verifiable.
- **Risks & open questions** — each with an owner or a fallback.
- **Boundaries** — what must not change, what must not break.

### 5. Confirm before handoff
Show the user the Objective, Scope, and Milestones. Get an explicit "yes" before this plan is handed to `run-the-plan`.

## Rationalizations — and the rebuttals
| Excuse | Rebuttal |
| --- | --- |
| "The idea is clear, skip the grilling." | If it were clear you could write the three-sentence restatement now. Write it. If you can't, grill. |
| "I'll figure out the unknowns while coding." | Unknowns resolved mid-build cause rewrites. A 10-minute spike now is cheaper than a 2-hour backtrack later. |
| "Scope is obvious." | Then writing the out-of-scope list costs nothing. Write it — that's where the disagreements hide. |
| "I don't need to cite the docs, I know this API." | Model memory drifts across versions. Verify, or mark it UNVERIFIED. |
| "A big plan is a better plan." | Length is not rigor. Cut anything that doesn't change a decision. |

## Red Flags — stop and fix
- You're writing code. This skill does not implement; hand off to `run-the-plan`.
- You asked more than one question in a single message.
- The plan asserts a technical fact you did not verify or flag.
- Milestones are organized by layer (all the backend, then all the UI) instead of thin end-to-end slices.
- There is no "Out of scope" or "Boundaries" section.

## Verification — the plan is done when
- `PLAN.md` exists with every required section filled.
- Every success criterion is observable (you could write a test or check for it).
- Every unknown is Decided or a named risk with a fallback.
- The user has explicitly confirmed Objective, Scope, and Milestones.
