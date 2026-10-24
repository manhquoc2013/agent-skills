<#
.SYNOPSIS
  ui-search.ps1 - Workspace shortcut to UI design intelligence search engine on Windows
#>
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SearchPy = Join-Path $RepoRoot "skills/frontend-ui-engineering/scripts/search.py"

if (-not (Test-Path $SearchPy)) {
    Write-Error "Error: Search engine not found at $SearchPy"
    exit 1
}

$PythonBin = ""
if (Get-Command python -ErrorAction SilentlyContinue) {
    $PythonBin = "python"
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $PythonBin = "py"
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $PythonBin = "python3"
} else {
    Write-Error "Error: Python 3 is required but not installed or not in PATH."
    exit 1
}

& $PythonBin $SearchPy @args
