#Requires -Version 5.1
<#
.SYNOPSIS
    Trava o teclado em Estados Unidos-Internacional e impede o Windows de voltar para o ABNT2.

.DESCRIPTION
    Desativa os atalhos de troca de layout, fixa o US-Internacional (00020409) como metodo
    de entrada padrao do usuario e remove os outros layouts da tela de login (pede UAC).
    Veja o README.md desta pasta para entender o motivo.

.PARAMETER AdminPart
    Uso interno: executa so a etapa elevada (tela de login). O script se relanca com ele.

.EXAMPLE
    .\lock-us-intl.ps1
    powershell -ExecutionPolicy Bypass -File .\lock-us-intl.ps1
#>
param([switch]$AdminPart)

$ErrorActionPreference = 'Stop'
$UsIntl = '00020409'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $AdminPart) {
    # ---- Parte 1: usuario atual (nao precisa de admin) ----

    # Desativa os atalhos de troca de idioma/layout (Alt+Shift, Ctrl+Shift)
    $toggle = 'HKCU:\Keyboard Layout\Toggle'
    if (-not (Test-Path $toggle)) { New-Item $toggle -Force | Out-Null }
    foreach ($name in 'Hotkey', 'Language Hotkey', 'Layout Hotkey') {
        Set-ItemProperty $toggle -Name $name -Value '3' -Type String
    }
    Write-Host '[ok] Atalhos Alt+Shift / Ctrl+Shift desativados'

    # Fixa US-Internacional como metodo de entrada padrao
    # (equivale a Set-WinDefaultInputMethodOverride -InputTip '0416:00020409')
    Set-ItemProperty 'HKCU:\Control Panel\International\User Profile' `
        -Name 'InputMethodOverride' -Value "0416:$UsIntl" -Type String
    Write-Host '[ok] Metodo de entrada padrao fixado em US-Internacional'

    # ---- Parte 2: tela de login / contas do sistema (precisa de admin) ----
    if (Test-Admin) {
        & $PSCommandPath -AdminPart
    } else {
        Write-Host '[..] Pedindo elevacao para ajustar a tela de login...'
        try {
            Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass',
                '-File', "`"$PSCommandPath`"", '-AdminPart'
            )
        } catch {
            Write-Warning 'Elevacao cancelada: o ABNT2 continua na tela de login.'
        }
    }

    Write-Host ''
    Write-Host 'Pronto. Saia da sessao e entre de novo para aplicar.'
    if ($Host.Name -eq 'ConsoleHost') { Read-Host 'Enter para fechar' | Out-Null }
    return
}

# ---- Execucao elevada: remove layouts que nao sejam US-Internacional do .DEFAULT ----
$preload = 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload'
$subst   = 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Substitutes'

$preKey = Get-Item $preload
$subKey = if (Test-Path $subst) { Get-Item $subst } else { $null }

$keep = @()
foreach ($name in ($preKey.GetValueNames() | Sort-Object { [int]$_ })) {
    $id = $preKey.GetValue($name)
    $real = if ($subKey -and $subKey.GetValue($id)) { $subKey.GetValue($id) } else { $id }
    if ($real -eq $UsIntl) { $keep += $id } else { Write-Host "[--] Removendo layout $id ($real) da tela de login" }
}

if ($keep.Count -eq 0) {
    Write-Warning 'Nenhum layout US-Internacional na tela de login; nada foi alterado.'
    Write-Warning 'Use intl.cpl > Administrativo > Copiar configuracoes.'
} else {
    foreach ($name in $preKey.GetValueNames()) { Remove-ItemProperty $preload -Name $name }
    $i = 1
    foreach ($id in $keep) {
        Set-ItemProperty $preload -Name "$i" -Value $id -Type String
        $i++
    }
    Write-Host '[ok] Tela de login agora so tem US-Internacional'
}
