$winget_verify = $env:winget_verify
& ".\core\wingetCheck.cmd"
if ($LASTEXITCODE -ne 0) { exit 1 }

Clear-Host
$ErrorActionPreference = 'SilentlyContinue'

# Configuração de Variáveis Globais
[int] $global:column = 0
[int] $separate = 30
[int] $global:lastPos = 50
[int] $global:item_count = 0
[int] $global:index = 0
[array] $global:items = @()
[bool] $global:install = $false

# Inicializa um item para seleção
function init_item {
    param(
        [string]$checkboxText,
        [string]$package
    )
    $global:items += , @($checkboxText, $package)
}

# Cria o checkbox para o software
function generate_checkbox {
    param(
        [string]$checkboxText,
        [string]$package,
        [bool]$enabled = $true
    )
    $checkbox = new-object System.Windows.Forms.checkbox
    if ($global:index -eq [math]::Ceiling($global:item_count / 2)) {
        $global:column = 1
        $global:lastPos = 50
    }
    if ($global:column -eq 0) {
        $checkbox.Location = new-object System.Drawing.Size(30, $global:lastPos)
    }
    else {
        $checkbox.Location = new-object System.Drawing.Size(($global:column * 300), $global:lastPos)
    }
    $global:lastPos += $separate
    $checkbox.Size = new-object System.Drawing.Size(250, 18)
    $checkbox.Text = $checkboxText
    $checkbox.Name = $package
    $checkbox.Enabled = $enabled

    $checkbox
}

# Carrega a lib de interface
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Define tamanho da pagina e grid
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Instalar Softwares" # Titulo da pagina 
$Form.ShowIcon = $false
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.Size = New-Object System.Drawing.Size(600, 210)
$Form.AutoSizeMode = 0
$Form.KeyPreview = $True
$Form.SizeGripStyle = 2

# Label principal
$Label = New-Object System.Windows.Forms.label
$Label.Location = New-Object System.Drawing.Size(11, 15)
$Label.Size = New-Object System.Drawing.Size(255, 15)                   
$Label.Text = "Download e instalando softwares com WinGet:"
$Form.Controls.Add($Label)

<#Inicializa os programas para seleção dos que serão instalados#>
init_item "Chromium" "eloston.ungoogled-chromium"                                   # Chromium
init_item "Google Chrome" "Google.Chrome"                                           # Google Chrome
init_item "OperaGX" "Opera.OperaGX"                                                 # OperaGX
init_item "Firefox" "Mozilla.Firefox"                                               # Firefox
init_item "Waterfox" "Waterfox.Waterfox"                                            # Waterfox
init_item "Brave Browser" "Brave.Brave"                                             # Brave Browser
init_item "LibreWolf" "LibreWolf.LibreWolf"                                         # LibreWolf
init_item "Tor Browser" "TorProject.TorBrowser"                                     # Tor Browser
init_item "Mozilla Thunderbird" "Mozilla.Thunderbird"                               # Mozilla Thunderbird
init_item "Discord" "Discord.Discord"                                               # Discord
init_item "Discord Canary" "Discord.Discord.Canary"                                 # Discord Canary
init_item "Steam" "Valve.Steam"                                                     # Steam
init_item "Playnite" "Playnite.Playnite"                                            # Playnite
init_item "Heroic" "HeroicGamesLauncher.HeroicGamesLauncher"                        # Heroic
init_item "Everything" "voidtools.Everything"                                       # Everything
init_item "foobar2000" "PeterPawlowski.foobar2000"                                  # foobar2000
init_item "IrfanView" "IrfanSkiljan.IrfanView"                                      # IrfanView
init_item "Git" "Git.Git"                                                           # Git
init_item "VLC" "VideoLAN.VLC"                                                      # VLC
init_item "PuTTY" "PuTTY.PuTTY"                                                     # PuTTY
init_item "7-Zip" "7zip.7zip"                                                       # 7-Zip
init_item "Teamspeak" "TeamSpeakSystems.TeamSpeakClient"                            # Teamspeak
init_item "Spotify" "Spotify.Spotify"                                               # Spotify
init_item "OBS Studio" "OBSProject.OBSStudio"                                       # OBS Studio
init_item "MSI Afterburner" "Guru3D.Afterburner"                                    # MSI Afterburner
init_item "CPU-Z" "CPUID.CPU-Z"                                                     # CPU-Z
init_item "GPU-Z" "TechPowerUp.GPU-Z"                                               # GPU-Z
init_item "Notepad++" "Notepad++.Notepad++"                                         # Notepad++
init_item "VSCode" "Microsoft.VisualStudioCode"                                     # VSCode
init_item "VSCodium" "VSCodium.VSCodium"                                            # VSCodium
init_item "JetBrains IntelliJ IDEA Community" "JetBrains.IntelliJIDEA.Community"    # JetBrains IntelliJ IDEA Community
init_item "Visual Studio Community 2022" "Microsoft.VisualStudio.2022.Community"    # Visual Studio Community 2022
init_item "BCUninstaller" "Klocman.BulkCrapUninstaller"                             # BCUninstaller
init_item "HWiNFO" "REALiX.HWiNFO"                                                  # HWiNFO
init_item "Lightshot" "Skillbrains.Lightshot"                                       # Lightshot
init_item "ShareX" "ShareX.ShareX"                                                  # ShareX
init_item "Snipping Tool (Microsoft)" "9MZ95KL8MR0L"                                # Snipping Tool
init_item "ExplorerPatcher" "valinet.ExplorerPatcher"                               # ExplorerPatcher
init_item "Powershell 7" "Microsoft.PowerShell"                                     # Powershell 7
init_item "UniGetUI" "MartiCliment.UniGetUI"                                        # UniGetUI
init_item "Transmission" "Transmission.Transmission"                                # Transmission
init_item "Epic Games Launcher" "EpicGames.EpicGamesLauncher"                       # Epic Games Launcher
init_item "GOG Galaxy" "GOG.Galaxy"                                                 # GOG Galaxy
init_item "Azul Zulu 22 JDK" "Azul.Zulu.22.JDK"                                     # Azul Zulu 22 JDK
init_item "Python 3.12" "Python.Python.3.12"                                        # Python 3.12
init_item "Node.js" "OpenJS.NodeJS"                                                 # Node.js
init_item "Postman" "Postman.Postman"                                               # Postman
init_item "Oracle VirtualBox" "Oracle.VirtualBox"                                   # Oracle VirtualBox
init_item "Hashicorp Vagrant" "Hashicorp.Vagrant"                                   # Hashicorp Vagrant
init_item "Docker Desktop" "Docker.DockerDesktop"                                   # Docker Desktop
init_item "LibreOffice" "TheDocumentFoundation.LibreOffice"                         # LibreOffice
init_item "EA app" "ElectronicArts.EADesktop"                                       # EA app
init_item "OpenVPN" "OpenVPNTechnologies.OpenVPN"                                   # OpenVPN
init_item "Chocolatey" "Chocolatey.Chocolatey"                                      # Chocolatey
init_item "Rust" "Rustlang.Rust.GNU"                                                # Rust

if ([System.Environment]::OSVersion.Version.Build -ge 22000) {
    # https://winget.run/pkg/StartIsBack/StartAllBack
    init_item "StartAllBack" "StartIsBack.StartAllBack"
}
else {
    # https://winget.run/pkg/StartIsBack/StartAllBack
    init_item "StartIsBack" "StartIsBack.StartIsBack"
}

# Conta os itens
$global:item_count = $global:items.Length

# Cria os checkbox e separa em duas colunas
foreach ($item in $global:items) {
    if ($global:index -eq ($global:item_count / 2)) {
        $global:column = 1
    }
    $Form.Controls.Add((generate_checkbox $item[0] $item[1]))
    $global:index ++
}

if ($global:column -ne 0) {
    $global:lastPos += $separate
}

$Form.height = $global:lastPos + 80

# Dark Mode/Light Mode 
$ToggleBtn = New-Object System.Windows.Forms.Button
$ToggleBtn.Location = New-Object System.Drawing.Point(500, 20)
$ToggleBtn.Size = New-Object System.Drawing.Size(80, 23)
$ToggleBtn.Add_Click({
    if ($this.Text -eq "Dark Mode") {
        $this.Text = "Light Mode"
        dark_mode
    }
    else {
        $this.Text = "Dark Mode"
        light_mode
    }
})

# Changed into functions
function dark_mode {
    $Form.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
    $Form.ForeColor = [System.Drawing.Color]::White
    foreach ($control in $Form.Controls) {
        if ($control.GetType().Name -eq "Checkbox") {
            $control.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
            $control.ForeColor = [System.Drawing.Color]::White
        }
    }
}

function light_mode {
    $Form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $Form.ForeColor = [System.Drawing.Color]::Black
    foreach ($control in $Form.Controls) {
        if ($control.GetType().Name -eq "Checkbox") {
            $control.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
            $control.ForeColor = [System.Drawing.Color]::Black
        }
    }
}

# Verifica o tema padrão do windows
$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\"
$keyName = "AppsUseLightTheme"
function check_system_theme {
    if (((Get-ItemProperty -Path $registryPath -Name $keyName).$keyName) -eq 0) {
        dark_mode
        $ToggleBtn.Text = "Light Mode"
    }
    else {
        light_mode
        $ToggleBtn.Text = "Dark Mode"
    }
}
check_system_theme

$Form.Controls.Add($ToggleBtn)

# Install Button
$lastPosWidth = $form.Width - 80 - 31
$InstallButton = new-object System.Windows.Forms.Button
$InstallButton.Location = new-object System.Drawing.Size($lastPosWidth, $global:lastPos)
$InstallButton.Size = new-object System.Drawing.Size(80, 23)
$InstallButton.Text = "Install"
$InstallButton.Add_Click({
        $checkedBoxes = $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Checkbox] -and $_.Checked }
        if ($checkedBoxes.Count -eq 0) {
            Read-MessageBox -Title "Nenhum pacote selecionado" -Body 'Por favor selecione um pacote para instalação!' -Icon Information -Buttons Ok | Out-Null
        }
        else {
            $global:install = $true
            $Form.Close()
        }
    })
$Form.Controls.Add($InstallButton)

# Ativa o formulário    
$Form.Add_Shown({ $Form.Activate() })
[void] $Form.ShowDialog()

# Instala os programas selecionados
if ($global:install) {
    $installPackages = [System.Collections.ArrayList]::new()
    $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Checkbox] } | ForEach-Object {
        if ($_.Checked) {
            [void]$installPackages.Add($_.Name)
        }
    }

    if ($installPackages.count -ne 0) {
        Write-Host "Instalando: " -ForegroundColor Yellow
        foreach ($a in $installPackages) {
            Write-Host "- " -NoNewline -ForegroundColor Blue
            Write-Host "$a"
        }
        Write-Host ""
        Start-Sleep 1

        # Percorre os programas selecionados e realiza a instalação
        foreach ($package in $installPackages) {
            & winget install -e --id $package --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h
        }
        Write-Host ""
        pause
    }
}