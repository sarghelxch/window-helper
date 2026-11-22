#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
;  WINDOW HELPER - RESIZE / CENTER / MOVE BETWEEN MONITORS
;  Version : 1.0.0
;  License : MIT
;  Repo    : https://github.com/<your-user>/window-helper
;
;  Ctrl+Alt+R        : resize & center on the current monitor
;  Ctrl+Alt+M        : move to the next monitor (cycle)
;  Ctrl+Alt+1 / 2    : move directly to monitor 1 / 2
;  Ctrl+Alt+Left     : move to the monitor physically on the left
;  Ctrl+Alt+Right    : move to the monitor physically on the right
; ============================================================

^!R::ResizeCenter()
^!M::MoveToNextMonitor()
^!1::MoveToMonitor(1)
^!2::MoveToMonitor(2)
^!Left::MoveDirectional(-1)
^!Right::MoveDirectional(1)


; ------------------------------------------------------------
;  RESIZE + CENTER ON THE CURRENT MONITOR
; ------------------------------------------------------------
ResizeCenter() {
    hwnd := WinExist("A")
    if !hwnd
        return

    if (WinGetMinMax(hwnd) != 0)          ; maximized/minimized -> restore first
        WinRestore(hwnd)

    mon := GetWindowMonitor(hwnd)
    MonitorGetWorkArea(mon, &wL, &wT, &wR, &wB)
    areaW := wR - wL
    areaH := wB - wT

    ; wide monitors (> 2560 px) -> 85%, otherwise 90%
    newW := Round(areaW * (areaW > 2560 ? 0.85 : 0.90))
    newH := Round(areaH * 0.90)

    newX := wL + (areaW - newW) // 2
    newY := wT + (areaH - newH) // 2

    WinMove(newX, newY, newW, newH, hwnd)

    ; correct the position if the app enforces a minimum window size
    WinGetPos(, , &realW, &realH, hwnd)
    if (realW != newW || realH != newH)
        WinMove(wL + (areaW - realW) // 2, wT + (areaH - realH) // 2, , , hwnd)
}


; ------------------------------------------------------------
;  MOVE TO THE NEXT MONITOR
; ------------------------------------------------------------
MoveToNextMonitor() {
    hwnd := WinExist("A")
    if !hwnd || (MonitorGetCount() < 2)
        return
    cur := GetWindowMonitor(hwnd)
    MoveToMonitor(Mod(cur, MonitorGetCount()) + 1)   ; 1->2->...->n->1
}


; ------------------------------------------------------------
;  MOVE TO A SPECIFIC MONITOR NUMBER
; ------------------------------------------------------------
MoveToMonitor(index) {
    hwnd := WinExist("A")
    if !hwnd
        return
    index := Min(Max(index, 1), MonitorGetCount())

    wasMax := (WinGetMinMax(hwnd) = 1)
    if (WinGetMinMax(hwnd) != 0)
        WinRestore(hwnd)

    WinGetPos(&wx, &wy, &ww, &wh, hwnd)
    if (ww <= 0 || wh <= 0)
        return

    MonitorGetWorkArea(index, &tL, &tT, &tR, &tB)
    areaW := tR - tL
    areaH := tB - tT

    ; shrink proportionally if the window is larger than the target area
    scale := Min(1.0, Min(areaW / ww, areaH / wh))
    newW := Round(ww * scale)
    newH := Round(wh * scale)

    newX := tL + (areaW - newW) // 2
    newY := tT + (areaH - newH) // 2

    WinMove(newX, newY, newW, newH, hwnd)

    if wasMax                            ; restore fullscreen on the new monitor
        WinMaximize(hwnd)
}


; ------------------------------------------------------------
;  MOVE LEFT / RIGHT (based on physical position)
; ------------------------------------------------------------
MoveDirectional(dir) {
    hwnd := WinExist("A")
    if !hwnd || (MonitorGetCount() < 2)
        return

    cur := GetWindowMonitor(hwnd)
    MonitorGet(cur, &cL, &cT, &cR, &cB)

    target := 0
    best := 0
    loop MonitorGetCount() {
        i := A_Index
        if (i = cur)
            continue
        MonitorGet(i, &L, &T, &R, &B)
        if (dir > 0) {                   ; look for one on the right
            if (L < cR)
                continue
            d := L - cR
        } else {                         ; look for one on the left
            if (R > cL)
                continue
            d := cL - R
        }
        if (!target || d < best) {       ; pick the nearest one
            target := i
            best := d
        }
    }
    if target
        MoveToMonitor(target)
}


; ------------------------------------------------------------
;  MONITOR THE WINDOW IS ON (based on its center point)
; ------------------------------------------------------------
GetWindowMonitor(hwnd) {
    WinGetPos(&wx, &wy, &ww, &wh, hwnd)
    cx := wx + ww // 2
    cy := wy + wh // 2
    loop MonitorGetCount() {
        MonitorGet(A_Index, &mL, &mT, &mR, &mB)
        if (cx >= mL && cx < mR && cy >= mT && cy < mB)
            return A_Index
    }
    return MonitorGetPrimary()
}
