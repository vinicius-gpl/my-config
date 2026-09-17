# ConPTY atualizado para o Alacritty (Windows 10)

## Problema

No Windows 10 o **zellij não funciona no Alacritty**, só no Windows Terminal.

## Causa

No Windows os programas de linha de comando não falam direto com o terminal. No meio
existe o **ConPTY** (Pseudo Console), que traduz a saída do programa em sequências de
escape (cores, cursor, mouse) e o teclado/mouse do terminal em entrada para o programa:

```
Alacritty  ⇄  ConPTY (host do console)  ⇄  pwsh / zellij
 (desenha)     (traduz sequências de terminal)   (o programa)
```

Existem duas versões do ConPTY:

| Versão | Onde fica | Processo host |
| --- | --- | --- |
| Do Windows | `kernel32.dll` (função `CreatePseudoConsole`) | `C:\Windows\system32\conhost.exe` |
| Separada | `conpty.dll` | `OpenConsole.exe` |

A do **Windows 10** (build 19045) é antiga e não recebe mais as correções que o zellij
precisa. O **Windows Terminal** (e o VS Code) trazem a versão separada junto, por isso o
zellij funciona neles.

## Solução

O Alacritty procura um `conpty.dll` **na mesma pasta do `alacritty.exe`**. Se encontrar,
usa essa versão; senão, volta para a do Windows. Basta colocar `conpty.dll` e
`OpenConsole.exe` ao lado do executável — nada é instalado no sistema.

## Origem dos arquivos

- Pacote NuGet oficial: [`Microsoft.Windows.Console.ConPTY`](https://www.nuget.org/packages/Microsoft.Windows.Console.ConPTY)
- Código-fonte (MIT): [github.com/microsoft/terminal](https://github.com/microsoft/terminal) — o mesmo do Windows Terminal
- Ambos os arquivos são assinados digitalmente por **Microsoft Corporation**; o script
  aborta se a assinatura não for válida.

Os binários **não são versionados** neste repositório: o script baixa sempre do NuGet.

## Uso

Feche todas as janelas do Alacritty e rode em **outro terminal** (ex.: Windows Terminal),
pois com o Alacritty aberto o `conpty.dll` fica travado:

```powershell
# Instalar a última versão estável
.\install-conpty.ps1

# Versão específica
.\install-conpty.ps1 -Version 1.24.260710001

# Pasta do Alacritty manual (se não estiver no PATH)
.\install-conpty.ps1 -AlacrittyDir "C:\caminho\alacritty"

# Desfazer (volta ao ConPTY do Windows)
.\install-conpty.ps1 -Uninstall
```

Se a política de execução bloquear o script:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-conpty.ps1
```

O script detecta a pasta pelo comando `alacritty` e resolve o shim do scoop
(`scoop\shims\alacritty.shim` → `scoop\apps\alacritty\current`).

> **Atenção (scoop):** `scoop update alacritty` cria uma pasta nova para a versão e os
> arquivos somem. **Rode o script novamente após cada atualização.**

## Verificar se está funcionando

Com o Alacritty aberto, o `conpty.dll` carregado deve ser o da pasta do Alacritty e o
`OpenConsole.exe` deve aparecer como processo filho:

```powershell
(Get-Process alacritty).Modules | Where-Object ModuleName -eq 'conpty.dll' | Select-Object FileName

Get-CimInstance Win32_Process -Filter "Name = 'OpenConsole.exe'" | Select-Object ProcessId, ParentProcessId, ExecutablePath
```

Se só aparecer `conhost.exe`, o Alacritty ainda está usando o ConPTY do Windows.
