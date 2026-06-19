param(
    [switch]$Once,
    [switch]$Autofix,
    [switch]$NoAutofix,
    [int]$Interval = 0,
    [int]$MaxAttempts = 10,
    [int]$WaitCi = 0,
    [string]$Step = "gate"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if ($NoAutofix) { $Autofix = $false }
if ($Once) { $MaxAttempts = 1; $Interval = 0 }

function Invoke-StepGate {
    param([string]$Name, [scriptblock]$Action)
    Write-Host "watch-agent-gates: running $Name"
    & $Action
    $code = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    if ($code -ne 0) {
        throw "$Name failed with exit $code"
    }
}

function Run-Step {
    param([string]$Label)
    switch ($Label) {
        "tm0" {
            Invoke-StepGate "validate-bootstrap-quick" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
            }
        }
        "tm1" {
            Invoke-StepGate "validate-bootstrap-quick" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
            }
        }
        "tm2" {
            Invoke-StepGate "validate-bootstrap-quick" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
            }
        }
        "tm3" {
            Invoke-StepGate "validate-bootstrap-quick" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
            }
        }
        "tm5" {
            Invoke-StepGate "validate-bootstrap-quick" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
            }
        }
        "tm6" {
            Invoke-StepGate "validate-bootstrap" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1")
            }
            Invoke-StepGate "repo-hygiene" {
                & (Join-Path $root "scripts\check-repo-hygiene.ps1")
            }
        }
        "tm4" {
            Invoke-StepGate "validate-bootstrap" {
                & (Join-Path $root "scripts\validate-bootstrap.ps1")
            }
            Invoke-StepGate "m0_smoke" {
                & (Join-Path $root "scripts\smoke\m0_smoke.ps1")
            }
        }
        "tm7" {
            Invoke-StepGate "feature-gate" {
                & (Join-Path $root "scripts\feature-gate.ps1") -Stack lightroom-rust
            }
        }
        "tm8" {
            Invoke-StepGate "m0_smoke" { & (Join-Path $root "scripts\smoke\m0_smoke.ps1") }
            Invoke-StepGate "m2_smoke" { & (Join-Path $root "scripts\smoke\m2_smoke.ps1") }
        }
        "tm9" {
            $tm = Join-Path $root "scripts\run-milestone-tm-gate.ps1"
            if (Test-Path $tm) { & $tm }
            else {
                & (Join-Path $root "scripts\validate-bootstrap.ps1")
                & (Join-Path $root "scripts\run-milestone-gate.ps1") -Milestone 2
            }
        }
        "scaffold" {
            & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
        }
        "tests" {
            & (Join-Path $root "scripts\smoke\m2_smoke.ps1")
            Push-Location (Join-Path $root "noclip-analyze")
            cargo test
            Pop-Location
        }
        "wire" {
            & (Join-Path $root "scripts\run-milestone-gate.ps1") -Milestone 2
        }
        default {
            & (Join-Path $root "scripts\validate-bootstrap.ps1") -Quick
        }
    }
}

$attempt = 0
while ($attempt -lt $MaxAttempts) {
    $attempt++
    Write-Host "watch-agent-gates attempt $attempt/$MaxAttempts step=$Step"
    try {
        Run-Step -Label $Step
        if ($WaitCi -gt 0) {
            $ci = Join-Path $root "scripts\check-github-ci.ps1"
            if (Test-Path $ci) {
                & $ci -WaitSeconds $WaitCi
            }
            else {
                Write-Host "INFO: check-github-ci.ps1 not installed; skip CI wait"
            }
        }
        Write-Host "watch-agent-gates: OK step=$Step"
        exit 0
    }
    catch {
        Write-Host "watch-agent-gates: $($_.Exception.Message)"
        if ($Autofix) {
            Write-Host "watch-agent-gates: no autofix hooks for NoClip yet; fix manually"
        }
        if ($Once -or $attempt -ge $MaxAttempts) {
            exit 1
        }
        if ($Interval -gt 0) {
            Start-Sleep -Seconds $Interval
        }
    }
}
exit 1
