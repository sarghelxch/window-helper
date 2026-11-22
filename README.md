# Window Helper

**English** | [Bahasa Indonesia](README.id.md)

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0%2B-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

An AutoHotkey v2 script to **resize, center, and move windows between monitors** on Windows 10/11 — without windows jumping back to the primary display.

---

## Why this exists

Most resize/center AutoHotkey snippets calculate window position using `A_ScreenWidth` and `A_ScreenHeight`. In AutoHotkey, both values **always refer to the primary monitor**, regardless of where the target window is. Since `WinMove` uses absolute virtual-desktop coordinates (with `(0,0)` at the top-left corner of the primary monitor), the result is that windows get pulled back to the main display.

This script fixes that by:

- Detecting **which monitor the window is currently on** (based on its center point).
- Calculating size and position relative to **that monitor's work area** (taskbar excluded).
- Never relying on the primary monitor's resolution.

---

## Features

- Resize and center the active window on the monitor it currently occupies.
- Move a window to the next monitor, or directly to a specific monitor number.
- Move a window by physical direction (left/right), so it stays correct even when Windows monitor numbering does not match the physical layout.
- Respects the monitor work area, so windows never end up hidden behind the taskbar.
- Handles maximized/fullscreen windows correctly.
- Automatically shrinks a window proportionally if it is larger than the target monitor.
- Corrects the final position when an application enforces a minimum window size.

---

## Requirements

| Requirement | Notes |
|---|---|
| OS | Windows 10 / Windows 11 |
| AutoHotkey | **v2.0 or newer** (not compatible with v1) |
| Monitors | 1 monitor for the resize features; **2+ monitors** for the move features |

---

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/) if you haven't already.
2. Save the script as `window-helper.ahk` (UTF-8 encoding).
3. Double-click the file to run it. An AHK icon appears in the system tray.
4. (Optional) To run it automatically at login:
   - Press `Win + R`, type `shell:startup`, and hit Enter.
   - Place a **shortcut** to `window-helper.ahk` in the folder that opens.

To stop the script: right-click the AHK tray icon → **Exit**.

---

## Usage

| Shortcut | Action |
|---|---|
| `Ctrl + Alt + R` | Resize and center the window on the monitor it is currently on |
| `Ctrl + Alt + M` | Move the window to the next monitor (cycles 1 → 2 → … → n → 1) |
| `Ctrl + Alt + 1` | Move the window to monitor 1 |
| `Ctrl + Alt + 2` | Move the window to monitor 2 |
| `Ctrl + Alt + ←` | Move to the monitor physically located on the left |
| `Ctrl + Alt + →` | Move to the monitor physically located on the right |

Behavior notes:

- `Ctrl + Alt + R` on a fullscreen window restores it into a normal, resized window.
- `Ctrl + Alt + M` and `Ctrl + Alt + 2` **preserve the fullscreen state**: the window is restored, moved, and maximized again on the target monitor.
- Window size is preserved when moving, unless the window is larger than the target monitor (in which case it is scaled down proportionally).

---

## How it works

```
Ctrl+Alt+R  →  GetWindowMonitor()  →  MonitorGetWorkArea()  →  compute size & center  →  WinMove()
Ctrl+Alt+M  →  GetWindowMonitor()  →  next monitor index    →  MoveToMonitor()
Ctrl+Alt+←/→ →  GetWindowMonitor()  →  nearest monitor in that direction  →  MoveToMonitor()
```

| Function | Responsibility |
|---|---|
| `ResizeCenter()` | Resizes the window to a percentage of the active monitor's work area, then centers it. |
| `MoveToNextMonitor()` | Determines the next monitor in sequence. |
| `MoveToMonitor(index)` | Moves the window to a specific monitor number and centers it. |
| `MoveDirectional(dir)` | Picks the target monitor based on physical position (left/right). |
| `GetWindowMonitor(hwnd)` | Returns the index of the monitor containing the window's center point. |

---

## Configuration

All settings live inside `ResizeCenter()`.

### Change the size percentages

```ahk
; wide monitors (> 2560 px) → 85%, otherwise 90%
newW := Round(areaW * (areaW > 2560 ? 0.85 : 0.90))
newH := Round(areaH * 0.90)
```

For example, to always use 80% width and 85% height:

```ahk
newW := Round(areaW * 0.80)
newH := Round(areaH * 0.85)
```

### Change the "wide monitor" threshold

Adjust the `2560` value to match your display (e.g. `1920` for FHD, `3840` for 4K).

### Add hotkeys for a third monitor and beyond

Add these next to the existing hotkey list at the top of the script:

```ahk
^!3::MoveToMonitor(3)
^!4::MoveToMonitor(4)
```

---

## Troubleshooting

**The window won't move or resize**
The target application may be running as administrator. Run AutoHotkey *as administrator* (right-click → Run as administrator), or launch the script via Task Scheduler with "Run with highest privileges" enabled.

**Position is off by a few pixels on mixed-DPI setups**
This is usually caused by differing DPI scaling between monitors (e.g. laptop at 150% + external monitor at 100%). Try adding the following line at the very top of the script, before any hotkey:

```ahk
DllCall("SetProcessDpiAwarenessContext", "Ptr", -4)
```

**UWP / Microsoft Store apps won't move**
Some UWP applications restrict window positioning by third-party programs. This is a Windows limitation, not a script bug.

**A hotkey does nothing**
It may conflict with another application using the same combination. Change the combination at the top of the script, for example `^!R` to `^!+R`.

**An error appears on launch**
Make sure you have AutoHotkey **v2** installed, not v1. This script uses v2 syntax (e.g. `WinMove(x, y, w, h, "A")`), which will not run on v1.

**The window snaps back to its old position**
Some applications store and restore their own window position. Try moving the window while it is in a normal (not minimized) state.

---

## Alternatives

Windows 10/11 already provides `Win + Shift + ←/→` to move windows between monitors. This script is useful when you also want **resize + center** and finer control, which the built-in shortcuts do not offer.

---

## Contributing

Issues and pull requests are welcome. If you report a bug, please include your Windows version, AutoHotkey version, and monitor layout (resolution + scaling).

---

## License

Released under the [MIT License](LICENSE).
