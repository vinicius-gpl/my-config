Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
(&mise activate pwsh) | Out-String | Invoke-Expression
oh-my-posh init pwsh --config ~/posh.json | Invoke-Expression
