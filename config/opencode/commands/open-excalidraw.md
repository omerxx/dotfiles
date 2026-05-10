---
description: Open a .excalidraw (or .excalidraw.md) file in Obsidian
agent: general
---

Open the requested Excalidraw file in Obsidian.

- Use `$ARGUMENTS` as the target path when provided.
- If no argument is provided, automatically pick the most recently modified `*.excalidraw` or `*.excalidraw.md` under the current directory.
- Resolve to an absolute path, verify the file exists, and then open it via Obsidian URI.
- Return the file path that was opened.

!`python3 - <<'PY'
from pathlib import Path
from urllib.parse import quote
import subprocess
import sys

raw_arguments = """$ARGUMENTS""".strip()

def latest_excalidraw_file(search_root: Path) -> Path | None:
    candidates = list(search_root.rglob("*.excalidraw"))
    candidates.extend(search_root.rglob("*.excalidraw.md"))
    files = [candidate for candidate in candidates if candidate.is_file()]
    if not files:
        return None
    return max(files, key=lambda candidate: candidate.stat().st_mtime)

if raw_arguments:
    target_path = Path(raw_arguments).expanduser()
    if not target_path.is_absolute():
        target_path = (Path.cwd() / target_path).resolve()
else:
    latest_file = latest_excalidraw_file(Path.cwd())
    if latest_file is None:
        print("No .excalidraw or .excalidraw.md files were found in the current directory.")
        sys.exit(1)
    target_path = latest_file.resolve()

if not target_path.exists() or not target_path.is_file():
    print(f"Target file does not exist: {target_path}")
    sys.exit(1)

obsidian_uri = f"obsidian://open?path={quote(str(target_path))}"
subprocess.run(["open", obsidian_uri], check=True)
print(f"Opened in Obsidian: {target_path}")
PY`
