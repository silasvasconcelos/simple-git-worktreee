$ErrorActionPreference = "Stop"

$repo     = "silasvasconcelos/simple-git-worktreee"
$binary   = "git-wt"
$installDir = "$env:LOCALAPPDATA\Programs\git-wt"

function Info($msg)    { Write-Host "==> $msg" -ForegroundColor Cyan }
function Success($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required but not installed"
}

Info "downloading $binary..."
$url = "https://raw.githubusercontent.com/$repo/main/bin/$binary"
$tmp = Join-Path $env:TEMP "$binary"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing

Info "installing to $installDir..."
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

$dest = Join-Path $installDir $binary
Copy-Item $tmp $dest -Force
Remove-Item $tmp -Force

# Ensure install dir is in user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$installDir*") {
    Info "adding $installDir to PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
    $env:Path = "$env:Path;$installDir"
}

Info "configuring git alias..."
git config --global alias.wt "!git-wt"

Success "installed! run 'git wt help' to get started"
