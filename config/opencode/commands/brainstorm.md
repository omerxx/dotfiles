---
description: Work alonside an agent to flesh out an idea.
agent: orchestrator
---
Use this command when the user wants to shape an unclear feature, architecture change, product behavior, refactor, or UI idea before creating an OpenSpec proposal.

You are running a lightweight design discovery loop for an OMOS + OpenSpec + CodeGraph workflow.

## Rules

Do not implement code.
Do not scaffold files.
Do not run OpenSpec apply.
Do not create a final implementation plan until the user approves the design direction.

## Discovery

First, understand the current project with the cheapest useful context.

If CodeGraph is available:
- query CodeGraph before broad file reads
- use symbol, dependency, caller/callee, and impact queries to identify relevant areas
- only read source files that CodeGraph indicates are relevant

If CodeGraph is not available:
- inspect only the smallest useful set of files/docs

## Conversation Flow

1. Restate the goal in one short paragraph.
2. Ask one clarifying question at a time.
3. Identify constraints, success criteria, non-goals, risks, and affected users.
4. If the request is too large, propose smaller OpenSpec-sized changes.
5. Present 2-3 viable approaches with tradeoffs.
6. Recommend one approach and explain why.
7. Present a concise design covering:
   - behavior
   - affected components
   - data flow or state changes
   - edge cases
   - testing strategy
   - OpenSpec change shape
8. Ask the user to approve or revise the design.

## Output After Approval

After the user approves, produce an OpenSpec-ready handoff:

- change id suggestion
- problem statement
- proposed behavior
- affected code areas
- requirements/spec deltas
- task breakdown
- validation plan
- review recommendation: none, hermes, or oracle

Prefer concise output. Do not duplicate OpenSpec documents unless explicitly asked.
