## OpenSpec Workflow

When a project contains `openspec/`, treat OpenSpec artifacts as the source of truth for non-trivial work.

Use OpenSpec when:
- The request changes product behavior, architecture, APIs, data flow, UX, permissions, persistence, or tests.
- The request is larger than a small obvious edit.
- Requirements are unclear and need exploration before implementation.
- The user asks for planning, specs, proposals, verification, or archive history.

Do not require OpenSpec for:
- Tiny one-file fixes.
- Formatting, typo fixes, simple renames, or mechanical chores.
- Quick investigation or explanation with no code change.

Workflow:
- For unclear work, start with `/opsx:explore`.
- For planned work, use `/opsx:propose <change>`.
- During implementation, use `/opsx:apply <change>` and treat `tasks.md` as the checklist.
- Before closing meaningful work, use `/opsx:verify`, then `/opsx:sync`, then `/opsx:archive`.

Discovery policy:
- If `.codegraph/` exists, use CodeGraph before broad file reads.
- Delegate broad discovery to @explorer.
- Delegate current external docs to @librarian.
- Delegate high-risk design review to @oracle.
- Delegate bounded implementation tasks to @fixer.
- Keep main-session context small; summarize findings into OpenSpec artifacts instead of pasting large code.

## OpenSpec Agent Routing

When executing OpenSpec commands, the Orchestrator owns the workflow and final decision. Delegate only bounded parts.

### /opsx:explore
Use @explorer for codebase discovery, especially if `.codegraph/` exists.
Use @librarian for current external docs.
Use @oracle only for high-risk architecture or ambiguous tradeoffs.
Do not write OpenSpec artifacts during explore unless the user asks to proceed.

### /opsx:propose
Orchestrator should create the proposal/spec/design/tasks.
Before writing artifacts:
- Use @explorer for repository facts and likely affected areas.
- Use @librarian for external API/library constraints.
- Use @oracle for architecture review when the change is large, risky, security-sensitive, or cross-system.
Keep artifacts concise and implementation-oriented.

### /opsx:apply
Orchestrator reads OpenSpec artifacts and owns task sequencing.
Use @fixer for bounded implementation tasks with clear file/module scope.
Use @designer for user-facing UI/UX tasks.
Use @explorer for targeted discovery before edits.
Use @oracle when implementation reveals a design problem or risky tradeoff.
Mark tasks complete only after verifying the corresponding code change.

### /opsx:verify
Verification should be stricter than normal implementation.
Use @hermes as the default cheap first-pass reviewer.
Use @oracle for correctness, coherence, maintainability, and spec/design adherence review when the change is meaningful or risky.
Use @explorer or CodeGraph for evidence gathering: affected symbols, callers/callees, routes, tests, and implementation locations.
Use @designer for UI/UX verification when the change affects visible interface behavior.
Use @fixer only to add or repair missing tests after verification identifies a concrete gap.
Do not archive if @oracle reports critical issues unless the user explicitly accepts the risk.

### /opsx:sync
Orchestrator owns spec syncing.
Do not delegate routine spec merge/sync work unless there are conflicts or ambiguity.
Use @oracle if spec deltas conflict, requirements are contradictory, or implementation differs from the planned design.

### /opsx:archive
Archive is a finalization step owned by Orchestrator.
Before archive:
- Prefer running `/opsx:verify` for non-trivial changes.
- Confirm tasks are complete.
- Confirm specs are synced or the user explicitly chooses to archive without syncing.
- If verification was skipped, use @hermes or @oracle for archive-readiness review on meaningful changes.
Do not use @fixer for archive except to fix concrete issues found before archiving.
Do not use codemap during archive unless the change altered durable architecture and the user asked to refresh maps.

### Default Routing Rule
OpenSpec controls the change contract. OMOS controls execution.
If OpenSpec and an agent suggestion conflict, preserve OpenSpec intent and ask the user before changing scope.

## Hermes Review Policy

Use @hermes as the default cheap first-pass reviewer.

Use @hermes when:
- A task or small OpenSpec change was just implemented.
- You want a quick review before `/opsx:verify`.
- The change is routine but still worth checking.
- You need a low-cost read on whether @oracle is necessary.

Use @oracle instead of @hermes when:
- The change affects architecture, auth, permissions, persistence, data integrity, concurrency, public APIs, or cross-module behavior.
- The implementation had design uncertainty.
- @hermes finds serious or uncertain issues.
- The user asks for deep review, simplification, YAGNI review, or final review on meaningful work.

For non-trivial OpenSpec changes:
1. Run @hermes first.
2. If @hermes finds critical/uncertain/high-risk issues, escalate to @oracle.
3. For major changes, run @oracle during `/opsx:verify` even if @hermes already reviewed.

## Simplify Skill Routing

Use @oracle with the `simplify` skill when:
- Implementation works but feels more complex than necessary.
- `/opsx:verify` finds coherence, maintainability, duplication, or over-engineering concerns.
- A completed OpenSpec change introduced broad conditionals, unclear names, duplicated logic, or avoidable abstractions.
- The user asks for cleanup, refactoring, maintainability review, or YAGNI review.

Do not use simplify before behavior is understood or before relevant tests pass.
Do not use simplify for unrelated drive-by refactors.
Keep simplification scoped to files changed by the current task unless the user explicitly asks for broader cleanup.

## Codemap Policy

Use codemap only when explicitly asked to create or refresh architecture maps, or when a change materially alters durable architecture.

If `.codegraph/` exists:
- Use CodeGraph first for discovery.
- Read only the minimum source needed to verify codemap claims.
- Keep codemaps concise.

Do not run codemap for routine OpenSpec changes, implementation-only edits, test-only edits, docs-only edits, formatting, or dependency lockfile churn.


## OpenSpec Task Execution Review Policy

When executing OpenSpec-backed implementation work, treat the OpenSpec proposal, design, tasks, and acceptance criteria as the source of truth.

### Routine Workflow
1. **Route implementation** to `@fixer`.
2. **Spec-compliance review**: Route to `@hermes` after implementation.
3. **Code-quality review**: If spec compliance passes, route to `@hermes`.
4. **Iterate**: If either review finds issues, send the work back to `@fixer` with specific findings.
5. **Resolve**: Repeat until the issue is resolved or the task is clearly blocked.

### High-Risk Work
Use `@oracle` instead of or after `@hermes` when changes affect:
- Architecture or Security
- Persistence or Concurrency
- Public APIs or Migrations
- Billing or Authentication
- Data loss risk or Cross-module behavior

### Review Criteria

#### 1. Spec-Compliance Review
- Did the implementation satisfy the OpenSpec task exactly?
- Did it miss any requirement or acceptance criterion?
- Did it add behavior that was not requested?
- Did it change scope without approval?

#### 2. Code-Quality Review
- Is the implementation simple, maintainable, and consistent with the repo?
- Are tests meaningful and scoped to the behavior?
- Did the change introduce unnecessary abstraction or complexity?
- Are there obvious correctness, edge-case, or integration risks?

### Guidelines
- **Trivial Edits**: Do not run the two-review loop for formatting, comments, docs, or mechanical renames unless high-risk.
- **Escalation**: If `@hermes` reports uncertainty, architectural concern, or repeated failure, escalate to `@oracle`.
- **Tooling**: Use CodeGraph before broad file reading. Prefer targeted symbol/call/reference queries.
- **Context**: Keep review prompts narrow. Provide only:
    - The OpenSpec task/acceptance criteria
    - Implementer summary
    - Changed files or diff summary
    - Relevant CodeGraph findings

---

## Parallel Execution Policy

Use parallel agents only when the OpenSpec task can be split into independent work units with disjoint context and write boundaries.

### Suitable Parallel Splits
- **Structural Separation**: Separate packages, modules, or folders.
- **Independent Failures**: Separate failing test files with likely independent causes.
- **Discovery**: Independent discovery tasks across unrelated subsystems.
- **Concurrent Investigation**: Implementation plus read-only investigation, provided the investigation does not block implementation.

### When to Avoid Parallelism
- One implementation decision affects all subtasks.
- Agents would edit the same files.
- The task requires a foundational architecture decision first.
- The OpenSpec acceptance criteria are ambiguous.
- The split increases review complexity beyond implementation benefits.

### Implementation Guidelines
- **Ownership**: Assign each `@fixer` explicit file or module ownership.
- **Boundaries**: Instruct `@fixer` agents not to modify files outside their scope without reporting the need first.
- **Reporting**: Require each `@fixer` to return:
    - Changed files
    - Behavior implemented
    - Tests touched
    - Identified risks
- **Integration**: Run the OpenSpec spec-compliance review after integrating all parallel work, rather than separately per fragment, unless fragments map to distinct tasks.

### Discovery Guidelines
- **Tooling**: Prefer `@explorer` or CodeGraph-backed queries.
- **Outputs**: Request concise findings with file paths and symbols instead of broad summaries.
- **Constraints**: Discovery agents must not rewrite architecture unless explicitly requested.

---

## Brainstorm Before OpenSpec

When the user asks to brainstorm, design, explore options, or shape an unclear idea, run the `/brainstorm` command before creating an OpenSpec proposal.

- **Trigger**: Use `/brainstorm` only when explicitly requested or when the user’s request is ambiguous enough that implementation would require guessing.
- **Workflow**: The output of `/brainstorm` should feed directly into the OpenSpec proposal creation.
- **Constraint**: Do not treat brainstorming as a replacement for OpenSpec; it is a precursor for clarity.
