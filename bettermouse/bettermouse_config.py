#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "rich>=13.0",
# ]
# ///
"""
BetterMouse Configuration Tool

Export and import BetterMouse settings to/from readable JSON.
Useful for backup, version control, or sharing configs.

Usage:
    uv run bettermouse_config.py export [output.json]
    uv run bettermouse_config.py import <input.json>
    uv run bettermouse_config.py show
    uv run bettermouse_config.py apply-thumbwheel

Or make executable and run directly:
    chmod +x bettermouse_config.py
    ./bettermouse_config.py show
"""

import plistlib
import json
import sys
import os
from pathlib import Path
from datetime import datetime
import base64

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box

# ============================================================================
# Configuration
# ============================================================================

PLIST_PATH = Path.home() / "Library/Preferences/com.naotanhaocan.BetterMouse.plist"
console = Console()

# Modifier key bitmasks (macOS CGEventFlags)
MODIFIERS = {
    "Shift": 0x20000,  # 131072
    "Control": 0x40000,  # 262144
    "Option": 0x80000,  # 524288
    "Command": 0x100000,  # 1048576
}

# Key codes for common keys
KEY_CODES = {
    123: "← Left",
    124: "→ Right",
    125: "↓ Down",
    126: "↑ Up",
    36: "↵ Return",
    49: "␣ Space",
    51: "⌫ Delete",
    53: "⎋ Escape",
    48: "⇥ Tab",
}

# Fields that are stored as nested binary plists
BINARY_PLIST_FIELDS = {"appitems", "mice", "keyboards", "config", "logikeys"}

# ============================================================================
# Utility Functions
# ============================================================================


def decode_modifiers(mod_value: int) -> str:
    """Decode a hotkeyMod bitmask into human-readable modifier names."""
    if not mod_value:
        return "None"
    mods = []
    symbols = {"Shift": "⇧", "Control": "⌃", "Option": "⌥", "Command": "⌘"}
    for name, mask in MODIFIERS.items():
        if mod_value & mask:
            mods.append(symbols.get(name, name))
    return "".join(mods) if mods else "None"


def decode_key(key_code: int) -> str:
    """Decode a key code into human-readable form."""
    return KEY_CODES.get(key_code, f"Key({key_code})")


# ============================================================================
# Plist Encoding/Decoding
# ============================================================================


def decode_nested(obj, depth=0):
    """Recursively decode nested binary plists to Python objects."""
    if isinstance(obj, dict):
        return {k: decode_nested(v, depth + 1) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [decode_nested(item, depth + 1) for item in obj]
    elif isinstance(obj, bytes):
        try:
            nested = plistlib.loads(obj)
            return decode_nested(nested, depth + 1)
        except Exception:
            return {
                "__binary__": base64.b64encode(obj).decode("ascii"),
                "__len__": len(obj),
            }
    elif isinstance(obj, datetime):
        return {"__datetime__": obj.isoformat()}
    else:
        return obj


def encode_nested(obj):
    """Recursively encode Python objects back to plist-compatible format."""
    if isinstance(obj, dict):
        if "__binary__" in obj:
            return base64.b64decode(obj["__binary__"])
        if "__datetime__" in obj:
            return datetime.fromisoformat(obj["__datetime__"])
        return {k: encode_nested(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [encode_nested(item) for item in obj]
    else:
        return obj


def encode_field_as_binary_plist(data: dict, field: str) -> bytes:
    """Encode a specific field back to binary plist format."""
    return plistlib.dumps(data, fmt=plistlib.FMT_BINARY)


# ============================================================================
# Thumbwheel Configuration
# ============================================================================


def create_thumbwheel_hotkey_config(
    direction: int, modifier: int, key_code: int
) -> dict:
    """Create a hotkey configuration for a thumbwheel direction."""
    return {
        "isHotkey": True,
        "hotkeyMod": modifier,
        "hotkeyKey": key_code,
    }


def build_thumbwheel_btn_config(
    left_mod: int, left_key: int, right_mod: int, right_key: int
) -> list:
    """
    Build the btn array structure for thumbwheel mappings.

    Structure: [button_id, gesture_config, ...]
    Button 31 = Thumbwheel
    """
    # Direction 6 = Left scroll, Direction 8 = Right scroll
    gesture_config = [
        0,  # Unknown purpose, seems required
        [
            {"Move": True},
            [
                6,  # Left direction
                create_thumbwheel_hotkey_config(6, left_mod, left_key),
                8,  # Right direction
                create_thumbwheel_hotkey_config(8, right_mod, right_key),
            ],
        ],
    ]

    return [31, gesture_config]


def apply_thumbwheel_config(
    left_mod: int = MODIFIERS["Option"],
    left_key: int = 123,  # Left arrow
    right_mod: int = MODIFIERS["Option"],
    right_key: int = 124,
) -> int:  # Right arrow
    """
    Apply thumbwheel hotkey configuration to BetterMouse.

    Default: Option+Left for thumbwheel left, Option+Right for thumbwheel right.
    This maps to AeroSpace workspace navigation.
    """
    console.print(
        Panel.fit(
            "[bold green]Applying Thumbwheel Configuration[/]", border_style="green"
        )
    )

    if not PLIST_PATH.exists():
        console.print(f"[red]✗[/] Plist not found: [dim]{PLIST_PATH}[/]")
        console.print("[dim]  Is BetterMouse installed?[/]")
        return 1

    # Read current config
    try:
        with open(PLIST_PATH, "rb") as f:
            plist = plistlib.load(f)
    except Exception as e:
        console.print(f"[red]✗[/] Failed to read plist: {e}")
        return 1

    console.print(f"[green]✓[/] Loaded: [dim]{PLIST_PATH}[/]")

    # Decode appitems (it's stored as binary plist)
    appitems_raw = plist.get("appitems", b"")
    if isinstance(appitems_raw, bytes) and appitems_raw:
        try:
            appitems = plistlib.loads(appitems_raw)
        except:
            appitems = {"apps": {}}
    else:
        appitems = {"apps": {}}

    # Ensure structure exists
    if "apps" not in appitems:
        appitems["apps"] = {}
    if "" not in appitems["apps"]:
        appitems["apps"][""] = {
            "enabled": True,
            "btn": [],
            "key": [],
        }

    # Build thumbwheel config
    thumbwheel_btn = build_thumbwheel_btn_config(
        left_mod, left_key, right_mod, right_key
    )

    # Get current btn config
    current_btn = appitems["apps"][""].get("btn", [])

    # Remove existing thumbwheel config (button 31)
    new_btn = []
    i = 0
    while i < len(current_btn):
        if i < len(current_btn) and current_btn[i] == 31:
            # Skip this button and its config
            i += 2
        else:
            new_btn.append(current_btn[i])
            if i + 1 < len(current_btn):
                new_btn.append(current_btn[i + 1])
            i += 2

    # Add our thumbwheel config
    new_btn.extend(thumbwheel_btn)
    appitems["apps"][""]["btn"] = new_btn

    # Backup existing
    backup_path = PLIST_PATH.with_suffix(".plist.backup")
    console.print(f"[yellow]⚠[/] Backing up to: [dim]{backup_path}[/]")
    try:
        import shutil

        shutil.copy2(PLIST_PATH, backup_path)
    except Exception as e:
        console.print(f"[yellow]⚠[/] Backup failed: {e}")

    # Re-encode appitems as binary plist
    plist["appitems"] = plistlib.dumps(appitems, fmt=plistlib.FMT_BINARY)

    try:
        with open(PLIST_PATH, "wb") as f:
            plistlib.dump(plist, f, fmt=plistlib.FMT_BINARY)
    except Exception as e:
        console.print(f"[red]✗[/] Failed to write: {e}")
        return 1

    import subprocess

    subprocess.run(["killall", "cfprefsd"], capture_output=True)

    console.print(f"[green]✓[/] Applied thumbwheel configuration")
    console.print()
    console.print("[bold]Configured mappings:[/]")
    console.print(
        f"  [cyan]◀ Thumbwheel Left[/]  → [green]⌥ ← (Option + Left Arrow)[/]"
    )
    console.print(
        f"  [cyan]▶ Thumbwheel Right[/] → [green]⌥ → (Option + Right Arrow)[/]"
    )
    console.print()
    console.print("[yellow]⚠ Restart BetterMouse for changes to take effect[/]")
    console.print("[dim]  Or: killall BetterMouse && open -a BetterMouse[/]")

    return 0


# ============================================================================
# Commands
# ============================================================================


def cmd_export(output_path: str = None) -> int:
    """Export BetterMouse config to JSON."""
    console.print(
        Panel.fit("[bold blue]BetterMouse Config Export[/]", border_style="blue")
    )

    if not PLIST_PATH.exists():
        console.print(f"[red]✗[/] Plist not found: [dim]{PLIST_PATH}[/]")
        console.print("[dim]  Is BetterMouse installed?[/]")
        return 1

    with console.status("[cyan]Reading plist...[/]"):
        try:
            with open(PLIST_PATH, "rb") as f:
                plist = plistlib.load(f)
        except Exception as e:
            console.print(f"[red]✗[/] Failed to read plist: {e}")
            return 1

    console.print(f"[green]✓[/] Loaded: [dim]{PLIST_PATH}[/]")

    with console.status("[cyan]Decoding nested plists...[/]"):
        decoded = decode_nested(plist)

    console.print("[green]✓[/] Decoded nested binary plists")

    # Generate output filename
    if not output_path:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_path = f"bettermouse_config_{timestamp}.json"

    with console.status(f"[cyan]Writing {output_path}...[/]"):
        try:
            with open(output_path, "w") as f:
                json.dump(decoded, f, indent=2)
        except Exception as e:
            console.print(f"[red]✗[/] Failed to write: {e}")
            return 1

    file_size = os.path.getsize(output_path)
    console.print(f"[green]✓[/] Exported: [bold]{output_path}[/] ({file_size:,} bytes)")

    # Show summary
    print_summary(decoded)
    return 0


def cmd_import(input_path: str) -> int:
    """Import BetterMouse config from JSON."""
    console.print(
        Panel.fit("[bold yellow]BetterMouse Config Import[/]", border_style="yellow")
    )

    if not os.path.exists(input_path):
        console.print(f"[red]✗[/] File not found: {input_path}")
        return 1

    with console.status("[cyan]Reading JSON...[/]"):
        try:
            with open(input_path, "r") as f:
                data = json.load(f)
        except Exception as e:
            console.print(f"[red]✗[/] Failed to read JSON: {e}")
            return 1

    console.print(f"[green]✓[/] Loaded: [bold]{input_path}[/]")

    # Read current plist to preserve structure
    if PLIST_PATH.exists():
        with open(PLIST_PATH, "rb") as f:
            current_plist = plistlib.load(f)
    else:
        current_plist = {}

    # Backup existing
    if PLIST_PATH.exists():
        backup_path = PLIST_PATH.with_suffix(".plist.backup")
        console.print(f"[yellow]⚠[/] Backing up to: [dim]{backup_path}[/]")
        try:
            import shutil

            shutil.copy2(PLIST_PATH, backup_path)
        except Exception as e:
            console.print(f"[yellow]⚠[/] Backup failed: {e}")

    with console.status("[cyan]Encoding to plist format...[/]"):
        # Encode the data, re-encoding binary plist fields
        encoded = encode_nested(data)

        # Re-encode known binary plist fields
        for field in BINARY_PLIST_FIELDS:
            if field in encoded and isinstance(encoded[field], dict):
                encoded[field] = plistlib.dumps(encoded[field], fmt=plistlib.FMT_BINARY)

    console.print("[green]✓[/] Encoded to plist format")

    with console.status("[cyan]Writing plist...[/]"):
        try:
            with open(PLIST_PATH, "wb") as f:
                plistlib.dump(encoded, f, fmt=plistlib.FMT_BINARY)
        except Exception as e:
            console.print(f"[red]✗[/] Failed to write: {e}")
            return 1

    console.print(f"[green]✓[/] Imported to: [dim]{PLIST_PATH}[/]")
    console.print("\n[yellow]⚠ Restart BetterMouse for changes to take effect[/]")
    return 0


def cmd_show() -> int:
    """Show current BetterMouse configuration summary."""
    console.print(
        Panel.fit("[bold cyan]BetterMouse Configuration[/]", border_style="cyan")
    )

    if not PLIST_PATH.exists():
        console.print(f"[red]✗[/] Plist not found: [dim]{PLIST_PATH}[/]")
        return 1

    try:
        with open(PLIST_PATH, "rb") as f:
            plist = plistlib.load(f)
        decoded = decode_nested(plist)
        print_summary(decoded)
        return 0
    except Exception as e:
        console.print(f"[red]✗[/] Failed: {e}")
        return 1


def print_summary(config: dict):
    """Print a beautiful summary of the configuration."""
    console.print()

    # Version info
    version = config.get("version", "Unknown")
    console.print(f"[dim]Config version:[/] [bold]{version}[/]")

    # Mice table
    mice = config.get("mice", {}).get("mice", [])
    if mice:
        table = Table(title="  Detected Mice", box=box.ROUNDED)
        table.add_column("Device", style="cyan")
        table.add_column("Vendor", style="dim")
        for mouse in mice:
            name = mouse.get("name", {})
            table.add_row(name.get("product", "Unknown"), name.get("vendor", "Unknown"))
        console.print(table)

    # Thumbwheel config
    appitems = config.get("appitems", {}).get("apps", {})

    table = Table(title="  Thumbwheel Hotkeys", box=box.ROUNDED)
    table.add_column("Context", style="bold")
    table.add_column("Direction", style="cyan")
    table.add_column("Hotkey", style="green")

    direction_names = {6: "◀ Left", 8: "▶ Right", 4: "● Press"}

    for app_id, app_config in appitems.items():
        app_name = app_id if app_id else "Global"
        btn_config = app_config.get("btn", [])

        i = 0
        while i < len(btn_config) - 1:
            btn_id = btn_config[i]
            if btn_id == 31:  # Thumbwheel
                gestures = btn_config[i + 1]
                parse_gestures_to_table(table, app_name, gestures, direction_names)
            i += 2

    if table.row_count > 0:
        console.print(table)
    else:
        console.print("[dim]No thumbwheel hotkeys configured[/]")

    # App exceptions
    exceptions = [k for k in appitems.keys() if k]
    if exceptions:
        console.print(
            f"\n[bold]App Exceptions:[/] {', '.join(f'[yellow]{e}[/]' for e in exceptions)}"
        )

    console.print()


def parse_gestures_to_table(
    table: Table, app_name: str, gestures, direction_names: dict
):
    """Parse thumbwheel gestures and add to table."""
    if not gestures or len(gestures) < 2:
        return

    gesture_data = gestures[1] if len(gestures) > 1 else gestures
    first_for_app = True

    i = 0
    while i < len(gesture_data):
        item = gesture_data[i]
        if isinstance(item, dict) and "Move" in item:
            if i + 1 < len(gesture_data):
                dir_configs = gesture_data[i + 1]
                if not isinstance(dir_configs, list):
                    i += 1
                    continue
                j = 0
                while j < len(dir_configs) - 1:
                    direction = dir_configs[j]
                    cfg = dir_configs[j + 1]
                    if isinstance(cfg, dict) and cfg.get("isHotkey"):
                        mod = decode_modifiers(cfg.get("hotkeyMod", 0))
                        key = decode_key(cfg.get("hotkeyKey", 0))
                        dir_name = direction_names.get(direction, f"Dir {direction}")

                        display_app = app_name if first_for_app else ""
                        table.add_row(display_app, dir_name, f"{mod} {key}")
                        first_for_app = False
                    j += 2
        i += 1


def print_usage():
    """Print usage information."""
    usage = """
[bold cyan]BetterMouse Configuration Tool[/]

[bold]Usage:[/]
    uv run bettermouse_config.py [green]export[/] [dim][output.json][/]
    uv run bettermouse_config.py [yellow]import[/] <input.json>
    uv run bettermouse_config.py [cyan]show[/]
    uv run bettermouse_config.py [magenta]apply-thumbwheel[/]

[bold]Commands:[/]
    [green]export[/]           Export config to JSON (auto-generates filename if omitted)
    [yellow]import[/]           Import config from JSON (creates backup first)
    [cyan]show[/]             Display current thumbwheel hotkey configuration
    [magenta]apply-thumbwheel[/] Apply default thumbwheel → Option+Arrow mappings

[bold]Examples:[/]
    [dim]# View current config[/]
    uv run bettermouse_config.py show

    [dim]# Export for backup[/]
    uv run bettermouse_config.py export my_config.json

    [dim]# Apply thumbwheel workspace navigation[/]
    uv run bettermouse_config.py apply-thumbwheel

    [dim]# Share with someone (they import it)[/]
    uv run bettermouse_config.py import shared_config.json

[bold]Thumbwheel Mapping (apply-thumbwheel):[/]
    [cyan]◀ Thumbwheel Left[/]  → [green]⌥ ← (Option + Left Arrow)[/] → Previous workspace
    [cyan]▶ Thumbwheel Right[/] → [green]⌥ → (Option + Right Arrow)[/] → Next workspace

    These map to AeroSpace workspace navigation commands.

[bold]Config Location:[/]
    [dim]{plist}[/]
""".format(plist=PLIST_PATH)
    console.print(usage)


# ============================================================================
# Main
# ============================================================================


def main() -> int:
    if len(sys.argv) < 2:
        print_usage()
        return 0

    cmd = sys.argv[1].lower()

    if cmd == "export":
        return cmd_export(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "import":
        if len(sys.argv) < 3:
            console.print("[red]✗[/] Import requires a file path")
            return 1
        return cmd_import(sys.argv[2])
    elif cmd == "show":
        return cmd_show()
    elif cmd in ["apply-thumbwheel", "apply"]:
        return apply_thumbwheel_config()
    elif cmd in ["-h", "--help", "help"]:
        print_usage()
        return 0
    else:
        console.print(f"[red]✗[/] Unknown command: {cmd}")
        print_usage()
        return 1


if __name__ == "__main__":
    sys.exit(main())
