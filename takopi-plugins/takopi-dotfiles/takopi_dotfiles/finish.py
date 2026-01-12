from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, cast

import anyio

from takopi.api import CommandContext, CommandResult, MessageRef, RunningTask, RunningTasks


def _decode_output(data: bytes) -> str:
    try:
        return data.decode("utf-8", errors="replace")
    except Exception:
        return repr(data)


def _select_cancel_target(
    ctx: CommandContext,
    *,
    running_tasks: RunningTasks,
    resolved_context: Any,
) -> tuple[MessageRef, RunningTask] | None:
    if ctx.reply_to is not None:
        task = running_tasks.get(ctx.reply_to)
        if task is not None:
            return ctx.reply_to, task

    if resolved_context is None:
        return None

    candidates: list[tuple[MessageRef, RunningTask]] = []
    for ref, task in running_tasks.items():
        if ref.channel_id != ctx.message.channel_id:
            continue
        if task.context != resolved_context:
            continue
        candidates.append((ref, task))

    if len(candidates) == 1:
        return candidates[0]

    return None


@dataclass(slots=True)
class FinishCommand:
    id: str = "finish"
    description: str = "cancel run and start PR auto-merge"

    async def handle(self, ctx: CommandContext) -> CommandResult | None:
        args_text = ctx.args_text.strip()
        resolved = ctx.runtime.resolve_message(
            text=args_text,
            reply_text=ctx.reply_text,
            chat_id=cast(int, ctx.message.channel_id),
        )

        run_cwd = ctx.runtime.resolve_run_cwd(resolved.context)
        if run_cwd is None:
            return CommandResult(
                text=(
                    "I can't tell which repo/worktree to finish.\n\n"
                    "Use one of:\n"
                    "- reply to a takopi message with `/finish`\n"
                    "- `/finish /<project> @<branch>`"
                )
            )

        cancelled = False
        cancel_detail = ""

        running_tasks_raw = getattr(ctx.executor, "_running_tasks", None)
        if isinstance(running_tasks_raw, dict):
            running_tasks = cast(RunningTasks, running_tasks_raw)
            target = _select_cancel_target(
                ctx,
                running_tasks=running_tasks,
                resolved_context=resolved.context,
            )
            if target is not None:
                ref, running_task = target
                running_task.cancel_requested.set()
                cancelled = True
                cancel_timeout_s = int(ctx.plugin_config.get("cancel_timeout_s", 60))
                try:
                    with anyio.fail_after(cancel_timeout_s):
                        await running_task.done.wait()
                except TimeoutError:
                    cancel_detail = (
                        f"(timed out after {cancel_timeout_s}s; continuing anyway)"
                    )
                else:
                    cancel_detail = f"(cancelled run from message {ref.message_id})"

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
        lines.append(f"finish: started completion workflow in {run_cwd}")
        if cancelled:
            lines.append(f"finish: cancel requested {cancel_detail}".rstrip())
        if result.returncode != 0:
            lines.append(f"finish: workflow start failed (exit {result.returncode})")
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
            lines.append("finish: workflow started, but couldn't parse log path.")
            lines.append("")
            lines.append(stdout[-3000:])

        return CommandResult(text="\n".join(lines))


BACKEND = FinishCommand()

