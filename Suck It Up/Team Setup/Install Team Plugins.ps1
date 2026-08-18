$ErrorActionPreference = "Stop"

$running = Get-Process -Name Obsidian -ErrorAction SilentlyContinue
if ($running) {
    Write-Host "Close Obsidian, then run this installer again." -ForegroundColor Yellow
    exit 2
}

$setupDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vaultRoot = (Resolve-Path -LiteralPath (Join-Path $setupDir "..\..")).Path
$bundleRoot = Join-Path $setupDir "Plugin Bundle\plugins"
$obsidianDir = Join-Path $vaultRoot ".obsidian"
$pluginRoot = Join-Path $obsidianDir "plugins"
$enabledPath = Join-Path $obsidianDir "community-plugins.json"
$teamPlugins = @("quickadd", "note-toolbar", "modalforms", "obsidian-excalidraw-plugin")

if (-not (Test-Path -LiteralPath $obsidianDir)) {
    throw "This setup folder is not inside an Obsidian vault: $vaultRoot"
}

New-Item -ItemType Directory -Path $pluginRoot -Force | Out-Null
foreach ($pluginId in $teamPlugins) {
    $source = Join-Path $bundleRoot $pluginId
    $target = Join-Path $pluginRoot $pluginId
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Missing bundled plugin: $pluginId"
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force
}

$enabled = @()
if (Test-Path -LiteralPath $enabledPath) {
    $enabled = @(Get-Content -Raw -LiteralPath $enabledPath | ConvertFrom-Json)
}
foreach ($pluginId in $teamPlugins) {
    if ($enabled -notcontains $pluginId) {
        $enabled += $pluginId
    }
}
$enabled | ConvertTo-Json | Set-Content -LiteralPath $enabledPath -Encoding utf8

Write-Host "Team plugins and settings are installed." -ForegroundColor Green
Write-Host "Open Obsidian and use this vault: $vaultRoot"

