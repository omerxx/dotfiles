# Tasks: Terminal Emulator

**Input**: Design documents from `/specs/001-terminal-emulator-tool/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)

```plain
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 3.1: Setup

- [x] T001 Create ghostty directory structure in /Users/david/Development/config/dotfiles/ghostty/

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [x] T002 [P] Contract test for ghostty config settings in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/contracts/ghostty-config.md
- [x] T003 [P] Integration test for truecolor rendering in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md
- [x] T004 [P] Integration test for tmux keybindings in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md
- [x] T005 [P] Integration test for shell respect in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md

## Phase 3.3: Core Implementation (ONLY after tests are failing)

- [x] T006 Implement ghostty config with all settings in /Users/david/Development/config/dotfiles/ghostty/config

## Phase 3.4: Integration

## Phase 3.5: Polish

- [x] T007 [P] Update quickstart.md if needed in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md
- [x] T008 Commit changes to branch

## Dependencies

- Tests (T002-T005) before implementation (T006)
- Implementation before polish (T007-T008)

## Parallel Example

```plain
# Launch T002-T005 together:
Task: "Contract test for ghostty config settings in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/contracts/ghostty-config.md"
Task: "Integration test for truecolor rendering in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md"
Task: "Integration test for tmux keybindings in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md"
Task: "Integration test for shell respect in /Users/david/Development/config/dotfiles/specs/001-terminal-emulator-tool/quickstart.md"
```

## Notes

- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules

*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task

2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks

3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist

*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests
- [x] All entities have model tasks (no entities)
- [x] All tests come before implementation
- [x] Parallel tasks truly independent
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
