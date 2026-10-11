<#
.SYNOPSIS
    Instala o ConPTY atualizado (conpty.dll + OpenConsole.exe) ao lado do alacritty.exe.

.DESCRIPTION
    Baixa o pacote oficial Microsoft.Windows.Console.ConPTY do NuGet, verifica a
    assinatura digital da Microsoft e copia os arquivos para a pasta do Alacritty.
    Veja o README.md desta pasta para entender o motivo.

.PARAMETER Version
    Versao do pacote no NuGet. Padrao: ultima versao estavel.

.PARAMETER AlacrittyDir
    Pasta onde esta o alacritty.exe. Padrao: detectada pelo comando "alacritty" (inclui shim do scoop).

.PARAMETER Uninstall
    Remove os arquivos, voltando a usar o ConPTY do Windows.

.EXAMPLE
    .\install-conpty.ps1
    .\install-conpty.ps1 -Version 1.24.260710001
    .\install-conpty.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [string] $Version,
    [string] $AlacrittyDir,
    [switch] $Uninstall
)

$ErrorActionPreference = 'Stop'
$files = 'conpty.dll', 'OpenConsole.exe'

# Localiza a pasta real do alacritty.exe (resolvendo o shim do scoop)
function Get-AlacrittyDir {
    $cmd = Get-Command alacritty -ErrorAction SilentlyContinue
    if (-not $cmd) { throw 'alacritty nao encontrado no PATH. Use -AlacrittyDir.' }

    $shim = [IO.Path]::ChangeExtension($cmd.Source, '.shim')
    if (Test-Path $shim) {
        $line = Get-Content $shim | Where-Object { $_ -match '^\s*path\s*=' } | Select-Object -First 1
        if ($line -match '"(.+)"') { return Split-Path $Matches[1] }
    }
    Split-Path $cmd.Source
}

if (-not $AlacrittyDir) { $AlacrittyDir = Get-AlacrittyDir }
if (-not (Test-Path (Join-Path $AlacrittyDir 'alacritty.exe'))) {
    throw "alacritty.exe nao encontrado em: $AlacrittyDir"
}
Write-Host "Pasta do Alacritty: $AlacrittyDir"

# Com o Alacritty aberto o conpty.dll fica travado e nao pode ser substituido
$running = Get-Process alacritty -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and (Split-Path $_.Path) -eq (Get-Item $AlacrittyDir).FullName }
if ($running) {
    throw 'Feche todas as janelas do Alacritty e rode este script em outro terminal (ex.: Windows Terminal).'
}

if ($Uninstall) {
    foreach ($f in $files) {
        $target = Join-Path $AlacrittyDir $f
        if (Test-Path $target) { Remove-Item $target -Force; Write-Host "Removido: $target" }
    }
    Write-Host 'Pronto. O Alacritty voltara a usar o ConPTY do Windows.'
    return
}

$arch = switch ($env:PROCESSOR_ARCHITECTURE) {
    'AMD64' { 'x64' }
    'ARM64' { 'arm64' }
    'x86'   { 'x86' }
    default { throw "Arquitetura nao suportada: $env:PROCESSOR_ARCHITECTURE" }
}

$feed = 'https://api.nuget.org/v3-flatcontainer/microsoft.windows.console.conpty'
if (-not $Version) {
    $Version = (Invoke-RestMethod "$feed/index.json").versions |
        Where-Object { $_ -notmatch '-' } |
        Select-Object -Last 1
}
Write-Host "Versao do ConPTY: $Version ($arch)"

$temp = Join-Path ([IO.Path]::GetTempPath()) "conpty-$Version"
$nupkg = "$temp.zip"
try {
    Invoke-WebRequest "$feed/$Version/microsoft.windows.console.conpty.$Version.nupkg" -OutFile $nupkg -UseBasicParsing
    Expand-Archive $nupkg $temp -Force

    $sources = @(
        Join-Path $temp "runtimes\win-$arch\native\conpty.dll"
        Join-Path $temp "build\native\runtimes\$arch\OpenConsole.exe"
    )

    # So copia se ambos estiverem assinados pela Microsoft
    foreach ($src in $sources) {
        if (-not (Test-Path $src)) { throw "Arquivo nao encontrado no pacote: $src" }
        $sig = Get-AuthenticodeSignature $src
        if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'CN=Microsoft Corporation') {
            throw "Assinatura invalida em $(Split-Path $src -Leaf): $($sig.Status) / $($sig.SignerCertificate.Subject)"
        }
        Write-Host "Assinatura OK: $(Split-Path $src -Leaf)"
    }

    Copy-Item $sources $AlacrittyDir -Force
    Write-Host "Instalado em $AlacrittyDir. Abra o Alacritty novamente."
}
finally {
    Remove-Item $nupkg, $temp -Recurse -Force -ErrorAction SilentlyContinue
}
