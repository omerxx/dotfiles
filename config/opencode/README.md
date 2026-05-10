# opencode/

## Purpose
Configuration and prompt assets for OpenCode tooling.

## Contents
- `opencode.json` — Main OpenCode config.
- `tui.json` — TUI-specific settings.
- `agent/` — Agent personas and role prompts.
- `command/` — Command prompt templates.
- `skills/ship/SKILL.md` — Custom skill definition.

## Current Stow target result
- `~/.config/opencode.json`
- `~/.config/tui.json`
- `~/.config/agent/...`
- `~/.config/command/...`
- `~/.config/skills/...`

## Usage status
- Might be valid if OpenCode is configured to read from these exact paths.
- If OpenCode expects `~/.config/opencode/...`, this is mis-targeted.

> Add the following to a projects openspec/config.yaml
```
context: |
  ## AI workflow:
  - OpenSpec is the source of truth for intent, scope, requirements, design, tasks, verification, and archive history.
  - oh-my-opencode-slim (OMOS) handles agent delegation and model routing.
  - CodeGraph is the first tool for code discovery, symbol lookup, call graphs, impact analysis, and affected tests.
  - Prefer cheap explorer agents for discovery and stronger models for design review or risky implementation.
  - Use Hermes as a cheap first-pass reviewer for routine changes.
  - Use Oracle for meaningful verification, architecture, security, data integrity, concurrency, persistence, public APIs, and cross-module behavior.
  - Keep token use low: query CodeGraph before reading files.
  - Do not refresh codemap unless explicitly requested or the change alters durable architecture.

  # Project: People Service (nxt-people)

  ## Purpose
  GraphQL-based microservice managing the people domain for AcuStaf's workforce management system.
  Handles people management, organizational structure, scheduling, job categories, and time-based assignments.

  ## Tech Stack
  - Language: Python 3.14+
  - API: Ariadne (GraphQL)
  - Framework: Uvicorn (ASGI)
  - Database: PostgreSQL with SQLAlchemy ORM 2.0+
  - Migrations: Alembic
  - Type Checking: MyPy (strict mode)
  - Formatting: Black (tab size 4)
  - Linting: Flake8 with flake8-bugbear
  - Testing: Pytest (pytest-mock, pytest-asyncio)
  - Validation: Pydantic 2.x
  - Auth: Auth0 with python-jose
  - Container: Docker & Docker Compose
  - Dependency Mgmt: Poetry
```