# Assinatura de commits com chave SSH (sem pedir senha toda hora)

## Problema

Assinar commits com a chave SSH protegida por senha faz o git pedir a senha **a cada
commit**, porque no Windows o agente SSH vem desativado.

## Causa

Quem assina é o `ssh-keygen`, e ele só deixa de pedir a senha se a chave estiver
carregada em um agente:

```
git commit  ->  ssh-keygen -Y sign  ->  ssh-agent (chave ja destravada)
```

Dois detalhes do Windows atrapalham:

| Detalhe | Efeito |
| --- | --- |
| O serviço `ssh-agent` (OpenSSH Authentication Agent) vem **Disabled** | Não há agente; a senha é pedida sempre |
| O Git for Windows traz um OpenSSH próprio | Ele não conversa com o agente do Windows |

Diferente do Linux, o agente do Windows **grava a chave no disco**, criptografada com o
login do usuário, e a recarrega sozinho. A senha é digitada uma vez só, e continua
valendo depois de reiniciar.

## Solução

O script [`enable-ssh-signing.ps1`](./enable-ssh-signing.ps1) faz, em ordem:

1. Liga o serviço `ssh-agent` e o deixa automático (pede UAC).
2. Guarda a chave no agente com `ssh-add` (pede a senha da chave uma única vez).
3. Configura o git global:

   | Configuração | Valor |
   | --- | --- |
   | `gpg.format` | `ssh` |
   | `user.signingkey` | caminho da chave pública |
   | `gpg.ssh.program` | `C:/Windows/System32/OpenSSH/ssh-keygen.exe` (o que fala com o agente) |
   | `commit.gpgsign` | `true` |

4. Copia a chave pública para a área de transferência.

Ele pula o que já estiver feito, então pode ser rodado de novo. Se o UAC for cancelado,
para antes de mexer no git.

A assinatura **não muda a autenticação**: o push continua funcionando como antes.

## Uso

Rode em um terminal interativo (a senha da chave é digitada nele):

```powershell
# Chave padrao: ~\.ssh\id_ed25519
.\enable-ssh-signing.ps1

# Outra chave
.\enable-ssh-signing.ps1 -KeyPath "$HOME\.ssh\outra_chave"
```

Se a política de execução bloquear o script:

```powershell
powershell -ExecutionPolicy Bypass -File .\enable-ssh-signing.ps1
```

Depois, cadastre a chave no GitHub em
[Settings → SSH and GPG keys → New SSH key](https://github.com/settings/ssh/new) com
**Key type: Signing Key**.

> **Atenção:** mesmo que a chave já esteja no GitHub como *Authentication Key*, é preciso
> adicioná-la de novo como *Signing Key*. E o `user.email` do git precisa ser um e-mail
> verificado na conta, senão o commit aparece como "Unverified".

## Verificar se está funcionando

```powershell
# Agente ativo e com a chave carregada
Get-Service ssh-agent | Select-Object Status, StartType
ssh-add -l

# Commit assinado sem pedir senha
git commit --allow-empty -m "teste de assinatura"
git cat-file commit HEAD    # deve ter um bloco "gpgsig -----BEGIN SSH SIGNATURE-----"
```

## Desfazer

```powershell
git config --global --unset commit.gpgsign
git config --global --unset gpg.format
git config --global --unset gpg.ssh.program
git config --global --unset user.signingkey

# Tira a chave do agente
ssh-add -d $HOME\.ssh\id_ed25519
```
