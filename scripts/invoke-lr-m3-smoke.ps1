param(
    [int]$WaitSec = 30
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $lr) {
    Write-Host "Lightroom not running"
    exit 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

[Win32]::ShowWindow($lr.MainWindowHandle, 9) | Out-Null
[Win32]::SetForegroundWindow($lr.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 500

Add-Type -AssemblyName System.Windows.Forms
# Library module: Alt+Ctrl/Shift+3 for Plug-in Extras varies — use File menu plug-in extras path
# File -> Plug-in Extras submenu is not reliably keyboard accessible.
# Send Alt+F then navigate — fragile on localized LR.

Write-Host "Lightroom foregrounded (PID $($lr.Id)). If auto-menu fails, run Library -> Plug-in Extras -> NoClip Auto — M3 Smoke (dev)"
exit 0
