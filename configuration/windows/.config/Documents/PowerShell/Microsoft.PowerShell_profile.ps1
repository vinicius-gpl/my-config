Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
oh-my-posh init pwsh --config "$env:LOCALAPPDATA\oh-my-posh\config.json" | Invoke-Expression
