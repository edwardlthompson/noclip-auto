param(
    [string]$MenuTitle = "NoClip Auto - M3 Smoke (dev)",
    [string]$ParentMenu = "Library",
    [int]$WaitForMenuSec = 90
)

$ErrorActionPreference = "Stop"

function Click-Element($element) {
    Add-Type -AssemblyName System.Drawing
    Add-Type @"
using System.Runtime.InteropServices;
public class MouseClick {
  [DllImport("user32.dll")] public static extern void mouse_event(int dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
}
"@
    $rect = $element.Current.BoundingRectangle
    if ($rect.Width -le 0 -or $rect.Height -le 0) {
        throw "Element has no clickable bounds: $($element.Current.Name)"
    }
    $x = [int]($rect.X + ($rect.Width / 2))
    $y = [int]($rect.Y + ($rect.Height / 2))
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    Start-Sleep -Milliseconds 150
    [MouseClick]::mouse_event(0x02, 0, 0, 0, 0)
    [MouseClick]::mouse_event(0x04, 0, 0, 0, 0)
}

function Find-NamedElement($parent, [string]$name, $scope) {
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty, $name)
    return $parent.FindFirst($scope, $cond)
}

function Get-ApplicationMenuBar($window) {
    $menuBarType = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::MenuBar)
    $menuBars = $window.FindAll([System.Windows.Automation.TreeScope]::Descendants, $menuBarType)
    foreach ($menuBar in $menuBars) {
        if ($menuBar.Current.Name -eq "Application") {
            return $menuBar
        }
    }
    return $null
}

function Find-OpenMenu($scopes, [int]$timeoutSec) {
    $menuType = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Menu)
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        foreach ($scope in $scopes) {
            if (-not $scope) { continue }
            $popup = $scope.FindFirst([System.Windows.Automation.TreeScope]::Children, $menuType)
            if ($popup) { return $popup }
        }
        Start-Sleep -Milliseconds 200
    }
    return $null
}

function Find-MenuItemByName($menu, [string]$name, [int]$timeoutSec) {
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        $el = Find-NamedElement $menu $name ([System.Windows.Automation.TreeScope]::Children)
        if ($el) { return $el }
        $el = Find-NamedElement $menu $name ([System.Windows.Automation.TreeScope]::Descendants)
        if ($el) { return $el }
        Start-Sleep -Milliseconds 200
    }
    return $null
}

function Invoke-NamedMenuItem($scopes, [string[]]$names, [int]$timeoutSec) {
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        $popup = Find-OpenMenu $scopes 1
        if ($popup) {
            foreach ($name in $names) {
                $item = Find-MenuItemByName $popup $name 1
                if ($item) {
                    Click-Element $item
                    return $true
                }
            }
        }
        Start-Sleep -Milliseconds 200
    }
    return $false
}

$lr = Get-Process -Name "Lightroom" -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } |
    Sort-Object StartTime -Descending |
    Select-Object -First 1
if (-not $lr) {
    throw "Lightroom is not running"
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Focus {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

[Win32Focus]::ShowWindow($lr.MainWindowHandle, 9) | Out-Null
[Win32Focus]::SetForegroundWindow($lr.MainWindowHandle) | Out-Null
Start-Sleep -Seconds 2

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

$root = [System.Windows.Automation.AutomationElement]::RootElement
$windowCond = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::ProcessIdProperty, $lr.Id)

$appMenuBar = $null
$window = $null
$deadline = (Get-Date).AddSeconds($WaitForMenuSec)
while ((Get-Date) -lt $deadline) {
    $window = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $windowCond)
    if ($window) {
        $appMenuBar = Get-ApplicationMenuBar $window
        if ($appMenuBar) { break }
    }
    Start-Sleep -Seconds 3
}

if (-not $appMenuBar) {
    throw "Application menu bar not found after ${WaitForMenuSec}s"
}

$parentItem = Find-NamedElement $appMenuBar $ParentMenu ([System.Windows.Automation.TreeScope]::Children)
if (-not $parentItem) {
    throw "$ParentMenu menu not found"
}

Click-Element $parentItem
Start-Sleep -Milliseconds 600

$scopes = @($appMenuBar, $window)
$extrasNames = @("Plug-in Extras", "Plug-In Extras", "Plugin Extras")
if (-not (Invoke-NamedMenuItem $scopes $extrasNames 8)) {
    throw "Plug-in Extras menu not found under $ParentMenu"
}

Start-Sleep -Milliseconds 600

if ($MenuTitle -eq "__probe__") {
    Write-Host "LR menu bar ready"
    exit 0
}

if (-not (Invoke-NamedMenuItem $scopes @($MenuTitle) 8)) {
    throw "Menu item not found: $MenuTitle"
}

Write-Host "Invoked menu: $MenuTitle"
