# Teclado travado em Estados Unidos-Internacional

## Problema

O Windows fica trocando o layout do teclado de **Estados Unidos-Internacional** para
**Português (Brasil ABNT2)** sozinho: depois de bloquear a tela, logar, abrir uma janela
de UAC ou encostar em um atalho sem querer.

## Causa

O layout ativo não vem de um lugar só. Três coisas deixam o ABNT2 voltar:

| Causa | Onde fica |
| --- | --- |
| A tela de login/bloqueio tem a própria lista de layouts, com o ABNT2 nela | `HKEY_USERS\.DEFAULT\Keyboard Layout\Preload` |
| Os atalhos de troca (Alt+Shift, Ctrl+Shift) vêm ativos | `HKCU\Keyboard Layout\Toggle` |
| Sem método de entrada padrão fixado, o Windows escolhe pela lista de idiomas | `HKCU\Control Panel\International\User Profile` |

Identificadores usados:

| Código | Layout |
| --- | --- |
| `00020409` | Estados Unidos-Internacional |
| `00000416` | Português (Brasil ABNT2) |
| `0416:00020409` | idioma pt-BR com teclado US-Internacional |

## Solução

O script [`lock-us-intl.ps1`](./lock-us-intl.ps1) faz três coisas:

1. Desativa os atalhos de troca de idioma/layout no usuário atual.
2. Fixa `0416:00020409` como método de entrada padrão do usuário atual.
3. Pede elevação (UAC) e remove da tela de login todo layout que não seja
   US-Internacional.

As duas primeiras não precisam de administrador; se o UAC for cancelado, elas continuam
aplicadas e só a tela de login fica como estava.

O script **não adiciona** o layout: o idioma pt-BR já precisa estar com o teclado
Estados Unidos-Internacional em Configurações → Hora e idioma → Idioma e região.

## Uso

```powershell
.\lock-us-intl.ps1
```

Se a política de execução bloquear o script:

```powershell
powershell -ExecutionPolicy Bypass -File .\lock-us-intl.ps1
```

Depois, **saia da sessão e entre de novo** para os atalhos e o padrão valerem.

> **Atenção:** atualizações grandes do Windows podem recolocar o ABNT2 como teclado
> padrão do idioma pt-BR. **Rode o script novamente se ele voltar.**

## Verificar se está funcionando

```powershell
# Usuario atual: so deve resolver para 00020409
Get-ItemProperty 'HKCU:\Keyboard Layout\Preload', 'HKCU:\Keyboard Layout\Substitutes'

# Atalhos: os tres valores devem ser 3
Get-ItemProperty 'HKCU:\Keyboard Layout\Toggle'

# Padrao fixado: deve ser 0416:00020409
(Get-ItemProperty 'HKCU:\Control Panel\International\User Profile').InputMethodOverride

# Tela de login: nao deve ter 00000416
Get-ItemProperty 'Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload'
```

## Desfazer

```powershell
# Reativa os atalhos (1 = Alt+Shift)
Set-ItemProperty 'HKCU:\Keyboard Layout\Toggle' -Name 'Hotkey', 'Language Hotkey' -Value '1'
Set-ItemProperty 'HKCU:\Keyboard Layout\Toggle' -Name 'Layout Hotkey' -Value '2'

# Remove o padrao fixado
Remove-ItemProperty 'HKCU:\Control Panel\International\User Profile' -Name 'InputMethodOverride'
```

Para devolver o ABNT2 à tela de login: `intl.cpl` → **Administrativo** →
**Copiar configurações**.
