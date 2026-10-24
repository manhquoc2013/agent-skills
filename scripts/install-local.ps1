#Requires -Version 5.1
<#
.SYNOPSIS
  Install agent-skills from this clone into IDE and CLI skill directories.

.DESCRIPTION
  Detects Cursor, Claude Code, Codex, Gemini CLI, Antigravity, Windsurf,
  OpenCode, GitHub Copilot, Copilot CLI, Kiro, and Command Code.
  Prints what is present and which destinations still need skills, then
  installs the selected targets. Copies real directories (no symlinks).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local.ps1 -List

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local.ps1

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local.ps1 -Only cursor,claude -Scope user

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local.ps1 -All -Scope project -Project C:\work\app
#>
[CmdletBinding()]
param(
    [switch]$List,
    [switch]$All,
    [switch]$Help,
    [switch]$Uninstall,
    [string[]]$Skills,
    [string[]]$Only,
    [ValidateSet('user', 'project')]
    [string]$Scope,
    [string]$Project
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$MarkerSkill = 'using-agent-skills'
$Script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Script:SkillsRoot = Join-Path $Script:RepoRoot 'skills'
$Script:ReferencesRoot = Join-Path $Script:RepoRoot 'references'

if ($Uninstall) {
    $uninstaller = Join-Path $PSScriptRoot 'uninstall-local.ps1'
    if (Test-Path -LiteralPath $uninstaller) {
        $forwardParams = @{}
        if ($List) { $forwardParams['List'] = $true }
        if ($All) { $forwardParams['All'] = $true }
        if ($Help) { $forwardParams['Help'] = $true }
        if ($Only) { $forwardParams['Only'] = $Only }
        if ($Skills) { $forwardParams['Skills'] = $Skills }
        if ($Scope) { $forwardParams['Scope'] = $Scope }
        if ($Project) { $forwardParams['Project'] = $Project }
        & $uninstaller @forwardParams
        exit $LASTEXITCODE
    }
}

function Show-InstallerHelp {
    Write-Host @"
install-local.ps1 — copy this clone's skills into detected IDE/CLI folders.

  -List                 Show detection and destinations, then exit
  -All                  Install every detected target (no menu)
  -Only <id[,id...]>    Install these ids even when not detected
  -Scope user|project   user = home config (default); project = one repo
  -Project <path>       Project root for -Scope project (default: current directory)
  -Uninstall            Uninstall skills from detected target(s)
  -Skills <s1[,s2...]>  Selectively remove only specified skills (with -Uninstall)
  -Help                 Show this text

Interactive menu (no -All / -Only):
  Enter   install every detected target that does not yet have skills
  a       install every detected target (refresh included)
  1,3,5   install those rows
  1-4     install a range
  q       quit

Ids: cursor, claude, codex, gemini, antigravity, windsurf, opencode,
     copilot, copilot-cli, kiro, commandcode
"@
}

function Get-PackVersion {
    $manifest = Join-Path $Script:RepoRoot '.claude-plugin\plugin.json'
    if (-not (Test-Path -LiteralPath $manifest)) {
        return 'unknown'
    }
    try {
        $json = Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.version) {
            return [string]$json.version
        }
    }
    catch {
        return 'unknown'
    }
    return 'unknown'
}

function Test-ToolCommand {
    param([string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Get-SourceSkillCount {
    $count = 0
    foreach ($dir in (Get-ChildItem -LiteralPath $Script:SkillsRoot -Directory -ErrorAction Stop)) {
        if (Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md')) {
            $count++
        }
    }
    return $count
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

function Test-MarkerInstalled {
    param([string]$Destination)
    $marker = Join-Path $Destination (Join-Path $MarkerSkill 'SKILL.md')
    return (Test-Path -LiteralPath $marker)
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
            Note = 'Open a new Cursor chat so the skill list reloads.'
        },
        @{
            Id = 'claude'
            Label = 'Claude Code'
            Commands = @('claude')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.claude'))
            UserSkills = (Join-Path $homeDir '.claude\skills')
            ProjectSkills = '.claude\skills'
            Note = 'Registers this clone with: claude plugin marketplace add <repo> && claude plugin install agent-skills@addy-agent-skills'
            Plugin = $true
        },
        @{
            Id = 'codex'
            Label = 'Codex'
            Commands = @('codex')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.codex'))
            UserSkills = (Join-Path $homeDir '.codex\skills')
            ProjectSkills = '.agents\skills'
            Note = 'Registers this clone with: codex plugin marketplace add <repo> && codex plugin add agent-skills@agent-skills'
            Plugin = $true
        },
        @{
            Id = 'gemini'
            Label = 'Gemini CLI'
            Commands = @('gemini')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.gemini'))
            UserSkills = (Join-Path $homeDir '.gemini\skills')
            ProjectSkills = '.gemini\skills'
            Note = 'Installs with: gemini skills install <repo>/skills'
            Plugin = $true
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
            Note = 'Installs the whole plugin with: agy plugin install <repo>. Antigravity keeps that plugin global.'
            Plugin = $true
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
            Note = 'This copies skill folders. Windsurf rules files stay untouched.'
        },
        @{
            Id = 'opencode'
            Label = 'OpenCode'
            Commands = @('opencode')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.config\opencode'))
            UserSkills = (Join-Path $homeDir '.config\opencode\skills')
            ProjectSkills = '.opencode\skills'
            Note = 'OpenCode reads .opencode/skills and ~/.config/opencode/skills.'
        },
        @{
            Id = 'copilot'
            Label = 'GitHub Copilot'
            Commands = @('code')
            Exes = @()
            ConfigDirs = @()
            UserSkills = (Join-Path $homeDir '.agents\skills')
            ProjectSkills = '.github\skills'
            Note = 'VS Code Copilot reads .github/skills in the project and ~/.agents/skills for the user.'
            DetectCopilot = $true
        },
        @{
            Id = 'copilot-cli'
            Label = 'Copilot CLI'
            Commands = @('copilot')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.copilot'))
            UserSkills = (Join-Path $homeDir '.copilot\skills')
            ProjectSkills = '.github\skills'
            Note = 'Registers this clone with: copilot plugin marketplace add <repo> && copilot plugin install agent-skills@addy-agent-skills'
            Plugin = $true
        },
        @{
            Id = 'kiro'
            Label = 'Kiro'
            Commands = @('kiro')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.kiro'))
            UserSkills = (Join-Path $homeDir '.kiro\skills')
            ProjectSkills = '.kiro\skills'
            Note = 'Kiro loads .kiro/skills (project) and ~/.kiro/skills (global).'
        },
        @{
            Id = 'commandcode'
            Label = 'Command Code'
            Commands = @('commandcode')
            Exes = @()
            ConfigDirs = @((Join-Path $homeDir '.commandcode'))
            UserSkills = (Join-Path $homeDir '.commandcode\skills')
            ProjectSkills = '.commandcode\skills'
            Note = 'Command Code also supports: cmd skills add <repo> from its own CLI.'
        }
    )
}

function Test-CopilotExtension {
    $codeCommand = $null
    if (Test-ToolCommand 'code') {
        $codeCommand = 'code'
    }
    else {
        if ($env:LOCALAPPDATA) {
            $codeExe = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe'
            if (Test-Path -LiteralPath $codeExe) {
                $codeCommand = $codeExe
            }
        }
    }
    if (-not $codeCommand) {
        return $false
    }
    try {
        $extensions = & $codeCommand --list-extensions 2>$null
        if (-not $extensions) {
            return $false
        }
        foreach ($name in $extensions) {
            if ([string]$name -match '^(?i)github\.copilot$') {
                return $true
            }
        }
    }
    catch {
        return $false
    }
    return $false
}

function Get-Detection {
    param($Entry)
    $reasons = New-Object System.Collections.Generic.List[string]
    foreach ($command in $Entry.Commands) {
        if (Test-ToolCommand $command) {
            $reasons.Add("command:$command")
        }
    }
    foreach ($exe in $Entry.Exes) {
        if ($exe -and (Test-Path -LiteralPath $exe)) {
            $reasons.Add('app')
        }
    }
    foreach ($dir in $Entry.ConfigDirs) {
        if ($dir -and (Test-Path -LiteralPath $dir)) {
            $reasons.Add('config')
        }
    }
    if ($Entry.ContainsKey('DetectCopilot') -and $Entry.DetectCopilot) {
        if (Test-CopilotExtension) {
            $reasons.Add('extension:github.copilot')
        }
        else {
            $withoutCode = @()
            foreach ($reason in $reasons) {
                if ($reason -ne 'command:code') {
                    $withoutCode += $reason
                }
            }
            $reasons = New-Object System.Collections.Generic.List[string]
            foreach ($reason in $withoutCode) {
                $reasons.Add($reason)
            }
        }
    }
    return [pscustomobject]@{
        Reasons = @($reasons.ToArray())
    }
}

function Resolve-SkillsDestination {
    param(
        $Entry,
        [string]$ScopeName,
        [string]$ProjectRoot
    )
    if ($ScopeName -eq 'project') {
        return (Join-Path $ProjectRoot $Entry.ProjectSkills)
    }
    return $Entry.UserSkills
}

function Get-RowState {
    param(
        [bool]$Found,
        [string]$Destination
    )
    $installed = Get-InstalledSkillCount $Destination
    $hasMarker = Test-MarkerInstalled $Destination
    if (-not $Found) {
        return [pscustomobject]@{ Status = 'absent'; Installed = $installed; Needs = $false }
    }
    if (-not $hasMarker) {
        return [pscustomobject]@{ Status = 'need'; Installed = $installed; Needs = $true }
    }
    return [pscustomobject]@{ Status = 'ready'; Installed = $installed; Needs = $false }
}

function Copy-SkillPack {
    param(
        [string]$DestinationSkills,
        [string]$Version
    )
    if (-not (Test-Path -LiteralPath $Script:SkillsRoot)) {
        throw "Skills directory not found: $Script:SkillsRoot"
    }
    New-Item -ItemType Directory -Force -Path $DestinationSkills | Out-Null
    $copied = 0
    foreach ($dir in (Get-ChildItem -LiteralPath $Script:SkillsRoot -Directory)) {
        $skillFile = Join-Path $dir.FullName 'SKILL.md'
        if (-not (Test-Path -LiteralPath $skillFile)) {
            continue
        }
        $target = Join-Path $DestinationSkills $dir.Name
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        Copy-Item -LiteralPath $dir.FullName -Destination $target -Recurse -Force
        $copied++
    }
    if (Test-Path -LiteralPath $Script:ReferencesRoot) {
        $referencesDestination = Join-Path (Split-Path -Parent $DestinationSkills) 'references'
        New-Item -ItemType Directory -Force -Path $referencesDestination | Out-Null
        Copy-Item -Path (Join-Path $Script:ReferencesRoot '*') -Destination $referencesDestination -Recurse -Force
    }
    $stamp = @{
        version = $Version
        installedAt = (Get-Date).ToUniversalTime().ToString('o')
        source = $Script:RepoRoot
        skillCount = $copied
    } | ConvertTo-Json
    $stampPath = Join-Path $DestinationSkills '.agent-skills-install.json'
    Set-Content -LiteralPath $stampPath -Value $stamp -Encoding UTF8
    return $copied
}

function Split-OnlyArgs {
    param([string[]]$Values)
    $ids = New-Object System.Collections.Generic.List[string]
    foreach ($value in $Values) {
        foreach ($part in ($value -split '[,\s]+')) {
            $trimmed = $part.Trim()
            if ($trimmed) {
                $ids.Add($trimmed.ToLowerInvariant())
            }
        }
    }
    return [string[]]$ids.ToArray()
}

function Get-RowByNumber {
    param(
        $Rows,
        [int]$Number
    )
    foreach ($row in @($Rows)) {
        if ([int]$row.Number -eq $Number) {
            return $row
        }
    }
    return $null
}

function Get-RowById {
    param(
        $Rows,
        [string]$Id
    )
    foreach ($row in @($Rows)) {
        if ([string]$row.Id -eq $Id) {
            return $row
        }
    }
    return $null
}

function Resolve-Selection {
    param(
        [string]$Answer,
        $Rows
    )
    $text = $Answer.Trim().ToLowerInvariant()
    $picked = New-Object System.Collections.Generic.List[string]
    if (-not $text) {
        foreach ($row in @($Rows)) {
            if ($row.Needs) {
                $picked.Add([string]$row.Id)
            }
        }
    }
    elseif ($text -eq 'q') {
        return @()
    }
    elseif ($text -eq 'a' -or $text -eq 'd') {
        foreach ($row in @($Rows)) {
            if ($row.Found) {
                $picked.Add([string]$row.Id)
            }
        }
    }
    else {
        foreach ($token in ($text -split '[,\s]+')) {
            if (-not $token) {
                continue
            }
            if ($token -match '^(\d+)\s*-\s*(\d+)$') {
                $start = [int]$Matches[1]
                $end = [int]$Matches[2]
                if ($start -gt $end) {
                    $swap = $start
                    $start = $end
                    $end = $swap
                }
                for ($number = $start; $number -le $end; $number++) {
                    $match = Get-RowByNumber -Rows $Rows -Number $number
                    if (-not $match) {
                        throw "Unknown row: $number"
                    }
                    $picked.Add([string]$match.Id)
                }
                continue
            }
            if ($token -match '^\d+$') {
                $match = Get-RowByNumber -Rows $Rows -Number ([int]$token)
                if (-not $match) {
                    throw "Unknown row: $token"
                }
                $picked.Add([string]$match.Id)
                continue
            }
            $byId = Get-RowById -Rows $Rows -Id $token
            if (-not $byId) {
                throw "Unknown id: $token"
            }
            $picked.Add([string]$byId.Id)
        }
    }
    $ordered = New-Object System.Collections.Generic.List[string]
    foreach ($id in $picked) {
        $seen = $false
        foreach ($existing in $ordered) {
            if ($existing -eq $id) {
                $seen = $true
                break
            }
        }
        if (-not $seen) {
            $ordered.Add($id)
        }
    }
    return [string[]]$ordered.ToArray()
}

if ($Help) {
    Show-InstallerHelp
    exit 0
}

if (-not (Test-Path -LiteralPath $Script:SkillsRoot)) {
    Write-Error "Expected skills at $Script:SkillsRoot"
    exit 1
}

$packVersion = Get-PackVersion
$sourceCount = Get-SourceSkillCount
$catalog = Get-HostCatalog

$scopeName = $Scope
$projectRoot = $null
if ($Scope -eq 'project' -or $Project) {
    if (-not $scopeName) {
        $scopeName = 'project'
    }
    if ($Project) {
        $projectRoot = (Resolve-Path -LiteralPath $Project).Path
    }
    else {
        $projectRoot = (Get-Location).Path
    }
}
$interactive = -not $List -and -not $All -and -not $Only
if (-not $PSBoundParameters.ContainsKey('Scope') -and $interactive) {
    Write-Host 'Scope: [U] user directories for every project, [P] project directory (current folder)'
    $scopeAnswer = (Read-Host 'Scope').Trim().ToLowerInvariant()
    if ($scopeAnswer -eq 'p' -or $scopeAnswer -eq 'project') {
        $scopeName = 'project'
        if (-not $projectRoot) {
            $projectRoot = (Get-Location).Path
        }
    }
    else {
        $scopeName = 'user'
    }
}
if (-not $scopeName) {
    $scopeName = 'user'
}

$rows = @()
$number = 1
foreach ($entry in $catalog) {
    $detection = Get-Detection $entry
    $reasons = @($detection.Reasons)
    $found = @($reasons | Where-Object { $_ }).Count -gt 0
    $destination = Resolve-SkillsDestination -Entry $entry -ScopeName $scopeName -ProjectRoot $(if ($projectRoot) { $projectRoot } else { (Get-Location).Path })
    $state = Get-RowState -Found $found -Destination $destination
    $rows += [pscustomobject]@{
        Number = $number
        Id = $entry.Id
        Label = $entry.Label
        Found = $found
        Reasons = ($reasons -join ', ')
        Status = $state.Status
        Installed = $state.Installed
        Needs = [bool]$state.Needs
        Destination = $destination
        Note = $entry.Note
        Plugin = ($entry.ContainsKey('Plugin') -and $entry.Plugin)
    }
    $number++
}

Write-Host "agent-skills $packVersion"
Write-Host "Source: $Script:SkillsRoot ($sourceCount skills)"
Write-Host "Scope:  $scopeName$(if ($scopeName -eq 'project') { " -> $projectRoot" })"
Write-Host ''
Write-Host ('{0,2}  {1,-14} {2,-9} {3,-8} {4,5}  {5}' -f '#', 'Id', 'Detected', 'Status', 'Have', 'Destination')
foreach ($row in $rows) {
    $detected = if ($row.Found) { 'yes' } else { 'no' }
    Write-Host ('{0,2}  {1,-14} {2,-9} {3,-8} {4,5}  {5}' -f $row.Number, $row.Id, $detected, $row.Status, $row.Installed, $row.Destination)
}
Write-Host ''
Write-Host 'Status: need = tool found, pack marker missing; ready = marker present; absent = tool not found.'

if ($List) {
    exit 0
}

$selectedIds = @()
if ($Only) {
    $selectedIds = @(Split-OnlyArgs $Only)
    $knownIds = New-Object System.Collections.Generic.List[string]
    foreach ($row in @($rows)) {
        $knownIds.Add([string]$row.Id)
    }
    foreach ($id in $selectedIds) {
        $matched = $false
        foreach ($knownId in $knownIds) {
            if ($knownId -eq $id) {
                $matched = $true
                break
            }
        }
        if (-not $matched) {
            Write-Error "Unknown id '$id'. Use -List to see ids."
            exit 1
        }
    }
}
elseif ($All) {
    $selectedIds = @($rows | Where-Object { $_.Found } | ForEach-Object { $_.Id })
    if ($selectedIds.Count -eq 0) {
        Write-Error 'No IDE or CLI detected. Pass -Only <id> to install a destination anyway.'
        exit 1
    }
}
else {
    Write-Host 'Enter = install every detected target with status need'
    Write-Host 'a = every detected target, 1,3 or 1-3 = choose rows, q = quit'
    $answer = Read-Host 'Install'
    try {
        $selectedIds = @(Resolve-Selection -Answer $answer -Rows $rows)
    }
    catch {
        Write-Error $_.Exception.Message
        exit 1
    }
    if ($selectedIds.Count -eq 0) {
        if ($answer.Trim().ToLowerInvariant() -eq 'q') {
            Write-Host 'Cancelled.'
            exit 0
        }
        Write-Host 'Nothing selected. Detected tools already have the pack marker, or none were detected.'
        Write-Host 'Choose row numbers, or pass -All to refresh detected targets.'
        exit 0
    }
}

function Invoke-MarketplaceInstall {
    param(
        $Row,
        [string]$ScopeName,
        [string]$ProjectRoot
    )
    $steps = New-Object System.Collections.Generic.List[object]
    $command = $null
    $claudeScope = 'user'
    if ($ScopeName -eq 'project') {
        $claudeScope = 'project'
    }
    switch ($Row.Id) {
        'claude' {
            $command = 'claude'
            $steps.Add(@('plugin', 'marketplace', 'add', $Script:RepoRoot, '--scope', $claudeScope))
            $steps.Add(@('plugin', 'install', 'agent-skills@addy-agent-skills', '--scope', $claudeScope))
        }
        'codex' {
            $command = 'codex'
            $steps.Add(@('plugin', 'marketplace', 'add', $Script:RepoRoot))
            $steps.Add(@('plugin', 'add', 'agent-skills@agent-skills'))
        }
        'gemini' {
            $command = 'gemini'
            if ($ScopeName -eq 'project') {
                $steps.Add(@('skills', 'install', $Script:SkillsRoot, '--scope', 'workspace'))
            }
            else {
                $steps.Add(@('skills', 'install', $Script:SkillsRoot))
            }
        }
        'antigravity' {
            $command = 'agy'
            $steps.Add(@('plugin', 'install', $Script:RepoRoot))
        }
        'copilot-cli' {
            $command = 'copilot'
            $steps.Add(@('plugin', 'marketplace', 'add', $Script:RepoRoot))
            $steps.Add(@('plugin', 'install', 'agent-skills@addy-agent-skills', '-y'))
        }
        default {
            return $false
        }
    }
    if (-not (Test-ToolCommand $command)) {
        Write-Host "  $command is not on PATH. Copying skill folders instead of registering the plugin."
        return $false
    }
    $workDir = $Script:RepoRoot
    if ($ScopeName -eq 'project' -and $ProjectRoot) {
        $workDir = $ProjectRoot
    }
    Push-Location $workDir
    try {
        foreach ($step in $steps) {
            $argList = @($step)
            Write-Host "  $command $($argList -join ' ')"
            & $command @argList
            if ($LASTEXITCODE -ne 0) {
                throw "$command exited with code $LASTEXITCODE"
            }
        }
    }
    finally {
        Pop-Location
    }
    return $true
}

$buildScript = Join-Path $Script:RepoRoot "scripts\build-agent-dist.js"
if (Test-Path $buildScript) {
    Write-Host "Synchronizing multi-agent configurations..."
    try {
        & node $buildScript *>$null
    } catch {
        # ignore if node is not on PATH
    }
}

$failures = New-Object System.Collections.Generic.List[string]
foreach ($id in @($selectedIds)) {
    $row = $null
    foreach ($candidate in @($rows)) {
        if ([string]$candidate.Id -eq [string]$id) {
            $row = $candidate
            break
        }
    }
    if (-not $row) {
        throw "No install target for selection '$id'."
    }
    Write-Host ''
    Write-Host "Installing $($row.Label)"
    try {
        $usedPlugin = $false
        if ($row.Plugin) {
            try {
                $usedPlugin = Invoke-MarketplaceInstall -Row $row -ScopeName $scopeName -ProjectRoot $projectRoot
            }
            catch {
                Write-Host "  Plugin command failed: $($_.Exception.Message)"
                Write-Host '  Copying skill folders instead.'
                $usedPlugin = $false
            }
        }
        if ($usedPlugin) {
            Write-Host '  Registered this clone as a plugin. Open a new session to load it.'
            if ($row.Id -eq 'antigravity') {
                Write-Host '  Antigravity installs that plugin for every project.'
            }
        }
        else {
            Write-Host "  Skill folders -> $($row.Destination)"
            $copied = Copy-SkillPack -DestinationSkills $row.Destination -Version $packVersion
            Write-Host "  Copied $copied skills."
            if (-not $row.Found) {
                Write-Host '  Tool was not detected. Folders were created for a later install of that IDE/CLI.'
            }
        }
        Write-Host "  $($row.Note)"
    }
    catch {
        $message = "$($row.Id): $($_.Exception.Message)"
        $failures.Add($message)
        Write-Host "  Failed: $message"
    }
}

Write-Host ''
if ($failures.Count -gt 0) {
    Write-Host "Finished with $($failures.Count) failure(s)."
    exit 1
}
Write-Host "Installed $($selectedIds.Count) target(s)."
exit 0
