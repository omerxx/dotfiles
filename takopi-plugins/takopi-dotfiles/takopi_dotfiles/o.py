from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, cast

import anyio
import secrets

from takopi.api import CommandContext, CommandResult, RunContext, RunRequest


def _decode_output(data: bytes) -> str:
    try:
        return data.decode("utf-8", errors="replace")
    except Exception:
        return repr(data)


def _extract_branch_directive(text: str) -> str | None:
    if not text:
        return None
    for raw_line in text.splitlines():
        line = raw_line.lstrip()
        if not line:
            continue
        tokens = line.split()
        for token in tokens:
            if token.startswith("/"):
                name = token[1:]
                if "@" in name:
                    name = name.split("@", 1)[0]
                if not name:
                    return None
                continue
            if token.startswith("@"):
                value = token[1:]
                return value or None
            return None
        return None
    return None


def _make_session_branch(prefix: str) -> str:
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
    suffix = "".join(secrets.choice(alphabet) for _ in range(6))
    return f"{prefix}/{ts}-{suffix}"


async def _git_current_branch(path: Path) -> str | None:
    result = await anyio.run_process(
        ["git", "-C", str(path), "branch", "--show-current"],
        check=False,
    )
    if result.returncode != 0:
        return None
    value = _decode_output(result.stdout).strip()
    return value or None


def _config_string(config: dict[str, Any], key: str) -> str | None:
    raw = config.get(key)
    if not isinstance(raw, str):
        return None
    value = raw.strip()
    return value or None


def _config_bool(config: dict[str, Any], key: str, default: bool) -> bool:
    raw = config.get(key)
    if raw is None:
        return default
    if isinstance(raw, bool):
        return raw
    return default


@dataclass(slots=True)
class OCommand:
    id: str = "o"
    description: str = "run opencode in a fresh worktree (like local `o`)"

    async def handle(self, ctx: CommandContext) -> CommandResult | None:
        args_text = ctx.args_text.strip()
        if not args_text:
            return CommandResult(
                text=(
                    "Usage:\n"
                    "- `/o <task>`\n"
                    "- `/o /<project> <task>`\n"
                    "- `/o /<project> @<branch> <task>`"
                )
            )

        resolved = ctx.runtime.resolve_message(
            text=args_text,
            reply_text=ctx.reply_text,
            chat_id=cast(int, ctx.message.channel_id),
        )

        explicit_branch = _extract_branch_directive(args_text)

        default_project = (
            _config_string(ctx.plugin_config, "default_project")
            or ctx.runtime.default_project
            or "dot"
        )

        project = (
            resolved.context.project
            if resolved.context is not None and resolved.context.project is not None
            else default_project
        )

        if ctx.runtime.normalize_project_key(project) is None:
            return CommandResult(
                text=(
                    f"Unknown project `{project}`.\n\n"
                    "Use one of:\n"
                    "- `/o /<project> <task>`\n"
                    "- `takopi init <project>`\n"
                    "- set `default_project` in `~/.takopi/takopi.toml`"
                )
            )

        project_key = project.lower()
        project_root = ctx.runtime.resolve_run_cwd(RunContext(project=project_key))
        if project_root is None:
            return CommandResult(
                text=(
                    f"Can't resolve project path for `{project}`.\n\n"
                    "Fix with: `takopi init <project>`"
                )
            )

        branch = explicit_branch or _make_session_branch(
            _config_string(ctx.plugin_config, "branch_prefix") or "oc"
        )

        banned = {"main", "master"}
        if explicit_branch and explicit_branch in banned:
            return CommandResult(
                text=(
                    f"`/o` refuses to run on `{explicit_branch}` (base branch).\n\n"
                    "Use `/finish` PR automation on a worktree branch instead."
                )
            )

        current_branch = await _git_current_branch(project_root)
        if explicit_branch and current_branch and explicit_branch == current_branch:
            return CommandResult(
                text=(
                    f"`/o` refuses to run on the project's current branch `{current_branch}`.\n\n"
                    "Use `/o @oc/<name> ...` or `/dot ...` if you truly want the main checkout."
                )
            )

        run_ctx = RunContext(project=project_key, branch=branch)
        run_cwd = ctx.runtime.resolve_run_cwd(run_ctx)
        if run_cwd is None:
            return CommandResult(
                text=(
                    "I can't resolve a worktree directory for this run.\n\n"
                    "Try: `takopi init <project>`"
                )
            )

        prompt = resolved.prompt.strip()
        if not prompt:
            return CommandResult(text="Missing task text after directives.")

        await ctx.executor.run_one(RunRequest(prompt=prompt, context=run_ctx))

        if not _config_bool(ctx.plugin_config, "auto_finish", False):
            return CommandResult(
                text=(
                    f"o: worktree kept for `{project}` @ `{branch}`\n"
                    "tip: resume locally with `o --session <ses_...>` "
                    "(OpenCode sessions are cwd-sensitive)\n"
                    "when ready to PR/merge/cleanup: reply `/finish`"
                )
            )

        script = Path.home() / ".config" / "opencode" / "completion-workflow-start.sh"
        if not script.exists():
            return CommandResult(
                text=f"Missing script: {script}\nExpected from ~/dotfiles/opencode/.",
            )

        result = await anyio.run_process(
            ["bash", str(script), "--repo", str(run_cwd)],
            cwd=str(run_cwd),
            check=False,
        )

        stdout = _decode_output(result.stdout).strip()
        stderr = _decode_output(result.stderr).strip()

        log_path = ""
        for line in reversed(stdout.splitlines()):
            line = line.strip()
            if line:
                log_path = line
                break

        lines: list[str] = []
        lines.append(f"o: completion workflow started for `{project}` @ `{branch}`")
        if result.returncode != 0:
            lines.append(f"o: workflow start failed (exit {result.returncode})")
            if stdout:
                lines.append("")
                lines.append("stdout:")
                lines.append(stdout[-3000:])
            if stderr:
                lines.append("")
                lines.append("stderr:")
                lines.append(stderr[-3000:])
            return CommandResult(text="\n".join(lines))

        if log_path:
            lines.append(f"log: {log_path}")
            lines.append("tip: enable takopi files, then `/file get <log>` to fetch it.")
        elif stdout:
            lines.append("o: workflow started, but couldn't parse log path.")
            lines.append("")
            lines.append(stdout[-3000:])

        return CommandResult(text="\n".join(lines))


BACKEND = OCommand()
