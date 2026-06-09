param(
    [int]$TimeoutSec = 180
)

$ErrorActionPreference = "Stop"

function Focus-Lr {
    $lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $lr) { throw "Lightroom is not running" }
    Add-Type @"
using System.Runtime.InteropServices;
public class Win32Focus {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
}
"@
    [Win32Focus]::ShowWindow($lr.MainWindowHandle, 9) | Out-Null
    [Win32Focus]::SetForegroundWindow($lr.MainWindowHandle) | Out-Null
    return $lr
}

function Find-ByName($parent, $name) {
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty, $name)
    return $parent.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
}

function Invoke-Ui($element) {
    $pattern = $element.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $pattern.Invoke()
}

function Open-PluginManager {
    Add-Type -AssemblyName System.Windows.Forms
    $root = [System.Windows.Automation.AutomationElement]::RootElement

    for ($i = 0; $i -lt 30; $i++) {
        Focus-Lr | Out-Null
        Start-Sleep -Milliseconds 400
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("%f")
        Start-Sleep -Milliseconds 500

        if ($i -gt 0) {
            for ($j = 0; $j -lt $i; $j++) {
                [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
                Start-Sleep -Milliseconds 80
            }
        }

        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Start-Sleep -Seconds 2

        $manager = Find-ByName $root "Plug-in Manager"
        if (-not $manager) { $manager = Find-ByName $root "Plugin Manager" }
        if ($manager) {
            Write-Host "Opened Plug-in Manager after File menu index $i"
            return $manager
        }
    }

    throw "Could not open Plug-in Manager"
}

$marker = Join-Path $env:TEMP "NoClipAuto\noclip-plugin-loaded.txt"
if (Test-Path $marker) {
    Write-Host "Plugin already loaded"
    exit 0
}

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

$root = [System.Windows.Automation.AutomationElement]::RootElement
$manager = Open-PluginManager

$pluginItem = Find-ByName $manager "NoClip Auto"
if (-not $pluginItem) {
    $add = Find-ByName $manager "Add"
    if (-not $add) { throw "Add button not found in Plug-in Manager" }
    Invoke-Ui $add
    Start-Sleep -Seconds 2

    $pluginPath = Join-Path $env:APPDATA "Adobe\Lightroom\Modules\NoClipAuto.lrdevplugin"
    [System.Windows.Forms.Clipboard]::SetText($pluginPath)
    [System.Windows.Forms.SendKeys]::SendWait("^l")
    Start-Sleep -Milliseconds 400
    [System.Windows.Forms.SendKeys]::SendWait("^v")
    Start-Sleep -Milliseconds 400
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 2
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 2

    $manager = Find-ByName $root "Plug-in Manager"
    if (-not $manager) { $manager = Find-ByName $root "Plugin Manager" }
    $pluginItem = Find-ByName $manager "NoClip Auto"
}

if (-not $pluginItem) {
    throw "NoClip Auto not found in Plug-in Manager"
}

Invoke-Ui $pluginItem
Start-Sleep -Milliseconds 500

$enable = Find-ByName $manager "Enable"
if ($enable) {
    $status = Find-ByName $manager "Status"
    $statusText = if ($status) { $status.Current.Name } else { "" }
    if ($statusText -notmatch "enabled") {
        Invoke-Ui $enable
        Start-Sleep -Seconds 3
    } else {
        Write-Host "Plugin already enabled; skipping Enable button"
    }
}

$done = Find-ByName $manager "Done"
if ($done) {
    Invoke-Ui $done
} else {
    [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
}

$deadline = (Get-Date).AddSeconds($TimeoutSec)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $marker) {
        Write-Host "Plugin enabled and loaded"
        exit 0
    }
    Start-Sleep -Seconds 3
}

throw "Plugin did not load after Plug-in Manager enable attempt"
