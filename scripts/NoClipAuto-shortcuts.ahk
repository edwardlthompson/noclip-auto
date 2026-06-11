#Requires AutoHotkey v2.0
; NoClip Auto — Lightroom Classic keyboard shortcuts (Windows)
; Install: https://www.autohotkey.com/  then double-click this file.
; Lightroom has no native plugin shortcut API on Windows (unlike macOS App Shortcuts).

#HotIf WinActive("ahk_exe Lightroom.exe")

; Ctrl+Alt+A — File > Plug-in Extras > Active Photo (works in Develop)
^!a::{
    try {
        WinMenuSelectItem("A", , "&File", "Plug-in Extras", "   NoClip Auto - Active Photo (File)")
    } catch {
        MsgBox("NoClip Auto: could not open File > Plug-in Extras > Active Photo (File).`n"
            . "Check the menu title matches exactly (3 leading spaces).", "NoClip Auto", "Icon!")
    }
}

; Ctrl+Alt+B — Library > Plug-in Extras > Selected Photos (batch)
^!b::{
    try {
        WinMenuSelectItem("A", , "&Library", "Plug-in Extras", "   NoClip Auto - Selected Photos")
    } catch {
        MsgBox("NoClip Auto: could not open Library > Plug-in Extras > Selected Photos.", "NoClip Auto", "Icon!")
    }
}

; Ctrl+Alt+Shift+A — Library > Plug-in Extras > Active Photo
^!+a::{
    try {
        WinMenuSelectItem("A", , "&Library", "Plug-in Extras", "   NoClip Auto - Active Photo")
    } catch {
        MsgBox("NoClip Auto: could not open Library > Plug-in Extras > Active Photo.", "NoClip Auto", "Icon!")
    }
}

#HotIf
