#Requires -Version 5.1
<#
.SYNOPSIS
    Configura o git para assinar commits com a chave SSH, sem pedir senha a cada commit.

.DESCRIPTION
    Liga o agente SSH do Windows (pede UAC), guarda a chave nele (pede a senha da chave
    uma unica vez) e configura a assinatura SSH no git global. No fim copia a chave
    publica para a area de transferencia, para cadastrar no GitHub como Signing Key.

.PARAMETER KeyPath
    Chave privada a usar. Padrao: ~\.ssh\id_ed25519

.PARAMETER AdminPart
    Uso interno: executa so a etapa elevada (servico ssh-agent). O script se relanca com ele.

.EXAMPLE
    .\enable-ssh-signing.ps1
    powershell -ExecutionPolicy Bypass -File .\enable-ssh-signing.ps1
#>
param(
    [string]$KeyPath = (Join-Path $HOME '.ssh\id_ed25519'),
    [switch]$AdminPart
)

$ErrorActionPreference = 'Stop'
$OpenSsh = Join-Path $env:SystemRoot 'System32\OpenSSH'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Enable-Agent {
    Set-Service ssh-agent -StartupType Automatic
    Start-Service ssh-agent
}

if ($AdminPart) {
    Enable-Agent
    return
}

$pubPath = "$KeyPath.pub"
if (-not (Test-Path $KeyPath) -or -not (Test-Path $pubPath)) {
    throw "Chave nao encontrada: $KeyPath (e $pubPath)"
}

# ---- 1. Agente SSH do Windows (precisa de admin) ----
$svc = Get-Service ssh-agent
if ($svc.Status -eq 'Running' -and $svc.StartType -eq 'Automatic') {
    Write-Host '[ok] ssh-agent ja esta ativo e automatico'
} elseif (Test-Admin) {
    Enable-Agent
    Write-Host '[ok] ssh-agent ativado'
} else {
    Write-Host '[..] Pedindo elevacao para ativar o ssh-agent...'
    try {
        Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass',
            '-File', "`"$PSCommandPath`"", '-AdminPart'
        )
    } catch {
        throw 'Elevacao cancelada: sem o ssh-agent o git pediria a senha a cada commit.'
    }
    if ((Get-Service ssh-agent).Status -ne 'Running') { throw 'O ssh-agent nao iniciou.' }
    Write-Host '[ok] ssh-agent ativado'
}

# ---- 2. Chave no agente (pede a senha da chave uma vez) ----
$fingerprint = ((& "$OpenSsh\ssh-keygen.exe" -lf $pubPath) -split ' ')[1]
$loaded = & "$OpenSsh\ssh-add.exe" -l
if ($loaded -match [regex]::Escape($fingerprint)) {
    Write-Host '[ok] Chave ja esta no agente'
} else {
    Write-Host '[..] Adicionando a chave ao agente (digite a senha da chave):'
    & "$OpenSsh\ssh-add.exe" $KeyPath
    if ($LASTEXITCODE -ne 0) { throw 'ssh-add falhou; a chave nao foi adicionada.' }
    Write-Host '[ok] Chave guardada no agente'
}

# ---- 3. Git: assinatura SSH ----
git config --global gpg.format ssh
git config --global user.signingkey ($pubPath -replace '\\', '/')
git config --global gpg.ssh.program (("$OpenSsh\ssh-keygen.exe") -replace '\\', '/')
git config --global commit.gpgsign true
Write-Host '[ok] Git configurado para assinar commits com a chave SSH'

# ---- 4. GitHub ----
Get-Content $pubPath -Raw | Set-Clipboard
Write-Host ''
Write-Host 'Chave publica copiada para a area de transferencia.'
Write-Host 'GitHub > Settings > SSH and GPG keys > New SSH key > Key type: Signing Key'
Write-Host '  https://github.com/settings/ssh/new'
Write-Host "O e-mail do git ($(git config --global user.email)) precisa estar verificado na conta."
if ($Host.Name -eq 'ConsoleHost') { Read-Host 'Enter para fechar' | Out-Null }
