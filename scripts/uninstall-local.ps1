#Requires -Version 5.1
<#
.SYNOPSIS
  Uninstall agent-skills from IDE and CLI skill directories.

.DESCRIPTION
  Removes installed skills across Cursor, Claude Code, Codex, Gemini CLI,
  Antigravity, Windsurf, OpenCode, GitHub Copilot, Copilot CLI, Kiro,
  and Command Code. Supports full cleanup or selective removal of specific skills.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-local.ps1 -List

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-local.ps1 -All

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-local.ps1 -Only cursor,claude

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-local.ps1 -Skills s-perf,s-debug
#>
[CmdletBinding()]
param(
    [switch]$List,
    [switch]$All,
    [switch]$Help,
    [string[]]$Only,
    [string[]]$Skills,
    [ValidateSet('user', 'project')]
    [string]$Scope = 'user',
    [string]$Project,
    [switch]$KeepAliases
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$MarkerSkill = 'using-agent-skills'
$Script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Script:SkillsRoot = Join-Path $Script:RepoRoot 'skills'
$Script:ReferencesRoot = Join-Path $Script:RepoRoot 'references'

function Show-UninstallerHelp {
    Write-Host @"
uninstall-local.ps1 — remove agent-skills from detected IDE/CLI folders.

  -List                 Show detection and installed skills, then exit
  -All                  Uninstall from every detected target (no menu)
  -Only <id[,id...]>    Uninstall only from these ids
  -Skills <s1[,s2...]>  Selectively remove only specified skills (e.g. s-perf,s-debug)
  -Scope user|project   user = home config (default); project = one repo
  -Project <path>       Project root for -Scope project
  -KeepAliases          Keep /s-* slash command aliases (do not remove them)
  -Help                 Show this text

Ids: cursor, claude, codex, gemini, antigravity, windsurf, opencode,
     copilot, copilot-cli, kiro, commandcode
"@
}

if ($Help) {
    Show-UninstallerHelp
    exit 0
}

function Test-ToolCommand {
    param([string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Get-InstalledSkillCount {
    param([string]$Destination)
    if (-not (Test-Path -LiteralPath $Destination)) {
        return 0
    }
    $count = 0
    foreach ($dir in (Get-ChildItem -LiteralPath $Destination -Directory -ErrorAction SilentlyContinue)) {
        if (Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md')) {
            $count++
        }
    }
    return $count
}

function Get-HostCatalog {
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { '' }
    $local = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } elseif ($homeDir) { $homeDir } else { '' }
    return @(
        @{
            Id = 'cursor'
            Label = 'Cursor'
            Commands = @('cursor')
            Exes = @(
                (Join-Path $local 'Programs\cursor\Cursor.exe'),
                (Join-Path $local 'cursor\Cursor.exe')
            )
            ConfigDirs = @((Join-Path $homeDir '.cursor'))
            UserSkills = (Join-Path $homeDir '.cursor\skills')
            ProjectSkills = '.cursor\skills'
        },
        @{
            Id = 'claude'
            Label = 'Claude Code'
            Commands = @('claude')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.claude'))
            UserSkills = (Join-Path $homeDir '.claude\skills')
            ProjectSkills = '.claude\skills'
        },
        @{
            Id = 'codex'
            Label = 'Codex'
            Commands = @('codex')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.codex'))
            UserSkills = (Join-Path $homeDir '.codex\skills')
            ProjectSkills = '.agents\skills'
        },
        @{
            Id = 'gemini'
            Label = 'Gemini CLI'
            Commands = @('gemini')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.gemini'))
            UserSkills = (Join-Path $homeDir '.gemini\skills')
            ProjectSkills = '.gemini\skills'
        },
        @{
            Id = 'antigravity'
            Label = 'Antigravity CLI'
            Commands = @('agy')
            Exes = @(
                (Join-Path $local 'Programs\Antigravity\Antigravity.exe')
            )
            ConfigDirs = @(
                (Join-Path $homeDir '.gemini\config\plugins'),
                (Join-Path $homeDir '.gemini\antigravity-cli')
            )
            UserSkills = (Join-Path $homeDir '.gemini\config\plugins\agent-skills\skills')
            ProjectSkills = '.agent\skills'
        },
        @{
            Id = 'windsurf'
            Label = 'Windsurf'
            Commands = @('windsurf')
            Exes = @(
                (Join-Path $local 'Programs\Windsurf\Windsurf.exe')
            )
            ConfigDirs = @((Join-Path $homeDir '.codeium\windsurf'))
            UserSkills = (Join-Path $homeDir '.codeium\windsurf\skills')
            ProjectSkills = '.windsurf\skills'
        },
        @{
            Id = 'opencode'
            Label = 'OpenCode'
            Commands = @('opencode')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.config\opencode'))
            UserSkills = (Join-Path $homeDir '.config\opencode\skills')
            ProjectSkills = '.opencode\skills'
        },
        @{
            Id = 'copilot'
            Label = 'GitHub Copilot'
            Commands = @('code')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.agents\skills'))
            UserSkills = (Join-Path $homeDir '.agents\skills')
            ProjectSkills = '.github\skills'
        },
        @{
            Id = 'copilot-cli'
            Label = 'Copilot CLI'
            Commands = @('copilot')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.copilot'))
            UserSkills = (Join-Path $homeDir '.copilot\skills')
            ProjectSkills = '.github\skills'
        },
        @{
            Id = 'kiro'
            Label = 'Kiro'
            Commands = @('kiro')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.kiro'))
            UserSkills = (Join-Path $homeDir '.kiro\skills')
            ProjectSkills = '.kiro\skills'
        },
        @{
            Id = 'commandcode'
            Label = 'Command Code'
            Commands = @('commandcode')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.commandcode'))
            UserSkills = (Join-Path $homeDir '.commandcode\skills')
            ProjectSkills = '.commandcode\skills'
        }
    )
}

function Resolve-Destination {
    param(
        [hashtable]$Target,
        [string]$ScopeMode,
        [string]$ProjectDirectory
    )
    if ($ScopeMode -eq 'project') {
        return (Join-Path $ProjectDirectory $Target.ProjectSkills)
    }
    return [string]$Target.UserSkills
}

function Test-TargetDetected {
    param([hashtable]$Target)
    foreach ($cmd in $Target.Commands) {
        if (Test-ToolCommand -Name $cmd) { return $true }
    }
    foreach ($exe in $Target.Exes) {
        if ($exe -and (Test-Path -LiteralPath $exe)) { return $true }
    }
    foreach ($cfg in $Target.ConfigDirs) {
        if ($cfg -and (Test-Path -LiteralPath $cfg)) { return $true }
    }
    return $false
}

$catalog = Get-HostCatalog
$projDir = if ($Project) { (Resolve-Path $Project).Path } else { (Get-Location).Path }

if ($List) {
    Write-Host "Scope: $Scope"
    if ($Scope -eq 'project') {
        Write-Host "Project: $projDir"
    }
    Write-Host ""
    $format = "{0,-4} {1,-16} {2,-10} {3,-12} {4}"
    [Console]::WriteLine(($format -f "#", "Tool", "Detected", "Installed", "Destination"))
    [Console]::WriteLine(($format -f "--", "----------------", "----------", "------------", "----------------------------------------"))
    $idx = 1
    foreach ($t in $catalog) {
        $dest = Resolve-Destination -Target $t -ScopeMode $Scope -ProjectDirectory $projDir
        $detected = if (Test-TargetDetected -Target $t) { "yes" } else { "no" }
        $installed = Get-InstalledSkillCount -Destination $dest
        [Console]::WriteLine(($format -f $idx, $t.Label, $detected, "$installed skills", $dest))
        $idx++
    }
    exit 0
}

# Parse selected IDs
$selectedIds = @()
if ($Only -and $Only.Count -gt 0) {
    foreach ($item in $Only) {
        $parts = $item -split ','
        foreach ($p in $parts) {
            $val = $p.Trim().ToLower()
            if ($val) { $selectedIds += $val }
        }
    }
}
elseif ($All) {
    foreach ($t in $catalog) {
        $dest = Resolve-Destination -Target $t -ScopeMode $Scope -ProjectDirectory $projDir
        if ((Test-TargetDetected -Target $t) -or ((Get-InstalledSkillCount -Destination $dest) -gt 0)) {
            $selectedIds += $t.Id
        }
    }
}
else {
    # Interactive menu
    $idx = 1
    Write-Host "Select targets to uninstall:"
    foreach ($t in $catalog) {
        $dest = Resolve-Destination -Target $t -ScopeMode $Scope -ProjectDirectory $projDir
        $det = if (Test-TargetDetected -Target $t) { "yes" } else { "no" }
        $inst = Get-InstalledSkillCount -Destination $dest
        Write-Host ("  [{0}] {1,-16} (Installed: {2} skills, Detected: {3})" -f $idx, $t.Label, $inst, $det)
        $idx++
    }
    Write-Host ""
    $ans = Read-Host "Target numbers (comma-separated, 'all', or Enter for all installed)"
    $ans = $ans.Trim().ToLower()
    if ($ans -eq 'all' -or $ans -eq 'a') {
        foreach ($t in $catalog) {
            if (Test-TargetDetected -Target $t) { $selectedIds += $t.Id }
        }
    }
    elseif (-not $ans) {
        foreach ($t in $catalog) {
            $dest = Resolve-Destination -Target $t -ScopeMode $Scope -ProjectDirectory $projDir
            if ((Get-InstalledSkillCount -Destination $dest) -gt 0) {
                $selectedIds += $t.Id
            }
        }
    }
    else {
        $tokens = $ans -split ','
        foreach ($tok in $tokens) {
            $num = 0
            if ([int]::TryParse($tok.Trim(), [ref]$num) -and $num -ge 1 -and $num -le $catalog.Count) {
                $selectedIds += $catalog[$num - 1].Id
            }
        }
    }
}

if ($selectedIds.Count -eq 0) {
    Write-Host "No targets selected."
    exit 0
}

# Clean destination
function Remove-SkillsFromDestination {
    param(
        [string]$Destination,
        [string[]]$SkillList
    )
    if (-not (Test-Path -LiteralPath $Destination)) {
        return 0
    }
    $removed = 0
    if ($SkillList -and $SkillList.Count -gt 0) {
        foreach ($s in $SkillList) {
            $targetDir = Join-Path $Destination $s.Trim()
            if (Test-Path -LiteralPath $targetDir) {
                Remove-Item -LiteralPath $targetDir -Recurse -Force
                $removed++
            }
        }
    }
    else {
        # Full uninstallation
        if (Test-Path -LiteralPath $Script:SkillsRoot) {
            foreach ($sub in (Get-ChildItem -LiteralPath $Script:SkillsRoot -Directory)) {
                $targetDir = Join-Path $Destination $sub.Name
                if (Test-Path -LiteralPath $targetDir) {
                    Remove-Item -LiteralPath $targetDir -Recurse -Force
                    $removed++
                }
            }
        }
        $stamp = Join-Path $Destination '.agent-skills-install.json'
        if (Test-Path -LiteralPath $stamp) {
            Remove-Item -LiteralPath $stamp -Force
        }
        $refDir = Join-Path (Split-Path $Destination -Parent) 'references'
        if (Test-Path -LiteralPath $refDir) {
            Remove-Item -LiteralPath $refDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        # Remove dir if empty
        if ((Get-ChildItem -LiteralPath $Destination -Force).Count -eq 0) {
            Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
        }
    }
    return $removed
}

Write-Host "=========================================================="
if ($Skills -and $Skills.Count -gt 0) {
    Write-Host ("Selectively Uninstalling Skill(s): {0}" -f ($Skills -join ', '))
} else {
    Write-Host "Uninstalling All Agent Skills"
}
Write-Host "Scope:   $Scope"
if ($Scope -eq 'project') { Write-Host "Project: $projDir" }
Write-Host ("Targets: {0}" -f ($selectedIds -join ', '))
Write-Host "=========================================================="
Write-Host ""

foreach ($id in $selectedIds) {
    $targetObj = $null
    foreach ($t in $catalog) {
        if ($t.Id -eq $id) { $targetObj = $t; break }
    }
    if (-not $targetObj) { continue }
    $dest = Resolve-Destination -Target $targetObj -ScopeMode $Scope -ProjectDirectory $projDir
    Write-Host "Processing $($targetObj.Label) ($id)..."
    $count = Remove-SkillsFromDestination -Destination $dest -SkillList $Skills
    Write-Host "  ✓ Removed $count skill(s) from $dest"
}

Write-Host ""
Write-Host "Uninstallation complete for $($selectedIds.Count) target(s)."
