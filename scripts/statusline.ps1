# scripts/statusline.ps1
# Fast PowerShell statusline indicator for terminal prompt or agent statusbar

$modeFlag = "$env:USERPROFILE\.config\agent-skills\mode"
$mode = "full"

if (Test-Path $modeFlag) {
    $mode = (Get-Content $modeFlag -TotalCount 1).Trim()
}

$phase = "READY"
if (Test-Path "tasks/todo.md") {
    $content = Get-Content "tasks/todo.md"
    $total = ($content | Select-String '^\s*-\s*\[[ xX]\]').Count
    $done = ($content | Select-String '^\s*-\s*\[[xX]\]').Count
    if ($total -gt 0) {
        if ($done -lt $total) {
            $pct = [math]::Round(($done * 100) / $total)
            $phase = "BUILD:$done/$total $pct%"
        } else {
            $phase = "REVIEW:100%"
        }
    } else {
        if ($content -match '- \[ \]') {
            $phase = "BUILD"
        } else {
            $phase = "REVIEW"
        }
    }
} elseif (Test-Path "tasks/plan.md") {
    $phase = "PLAN"
} elseif (Test-Path "SPEC.md") {
    $phase = "SPEC"
}

Write-Host "[$($phase):$($mode.ToUpper())]" -NoNewline
