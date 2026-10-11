<#
.SYNOPSIS
    Sincroniza os dotfiles do Windows para os locais padrões do sistema.
.DESCRIPTION
    Copia ou cria symlinks para:
    - Alacritty (%APPDATA%\alacritty)
    - PowerShell Profile ($PROFILE)
    - WezTerm ($HOME\.wezterm.lua)
    - Zellij (%APPDATA%\zellij\config\config.kdl)
    - Oh My Posh ($HOME\posh.json)
    - Git Hooks ($HOME\.config\.git-hooks)
#>

[CmdletBinding()]
param(
    [switch]$UseSymlinks
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path "$scriptDir\..\..\..\.."
$dotfilesWin = "$repoRoot\configuration\desktop\dotfiles\windows"

if (-not (Test-Path $dotfilesWin)) {
    Write-Error "Diretório de dotfiles do Windows não encontrado em: $dotfilesWin"
    exit 1
}

Write-Host "🚀 Iniciando sincronização dos dotfiles do Windows..." -ForegroundColor Cyan

function Install-ConfigItem {
    param(
        [string]$Source,
        [string]$DestinationDir,
        [string]$DestinationFileName = $null
    )

    if (-not (Test-Path $DestinationDir)) {
        New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    }

    $destPath = if ($DestinationFileName) { Join-Path $DestinationDir $DestinationFileName } else { $DestinationDir }

    if ($UseSymlinks) {
        if (Test-Path $destPath) { Remove-Item -Force -Recurse $destPath }
        New-Item -ItemType SymbolicLink -Path $destPath -Target $Source | Out-Null
        Write-Host "  [Symlink] $Source -> $destPath" -ForegroundColor Gray
    } else {
        Copy-Item -Path $Source -Destination $destPath -Recurse -Force
        Write-Host "  [Copiado] $Source -> $destPath" -ForegroundColor Gray
    }
}

# 1. Alacritty
Install-ConfigItem -Source "$dotfilesWin\alacritty\*" -DestinationDir "$env:APPDATA\alacritty"

# 2. PowerShell Profile
$psDir = Split-Path $PROFILE
Install-ConfigItem -Source "$dotfilesWin\powershell\Microsoft.PowerShell_profile.ps1" -DestinationDir $psDir -DestinationFileName (Split-Path -Leaf $PROFILE)

# 3. WezTerm
Install-ConfigItem -Source "$dotfilesWin\wezterm\.wezterm.lua" -DestinationDir "$HOME" -DestinationFileName ".wezterm.lua"

# 4. Zellij
Install-ConfigItem -Source "$dotfilesWin\zellij\config.kdl" -DestinationDir "$env:APPDATA\zellij\config" -DestinationFileName "config.kdl"

# 5. Oh My Posh Theme
Install-ConfigItem -Source "$dotfilesWin\posh\posh.json" -DestinationDir "$HOME" -DestinationFileName "posh.json"

# 6. Git Hooks Globais
Install-ConfigItem -Source "$dotfilesWin\git-hooks\prepare-commit-msg" -DestinationDir "$HOME\.config\.git-hooks" -DestinationFileName "prepare-commit-msg"
git config --global core.hooksPath "$HOME\.config\.git-hooks"

Write-Host "`n✅ Dotfiles do Windows sincronizados com sucesso!" -ForegroundColor Green
