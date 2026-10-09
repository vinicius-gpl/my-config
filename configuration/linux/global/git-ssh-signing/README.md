# Assinatura de commits com chave SSH (sem pedir senha toda hora)

Versão Linux do [`enable-ssh-signing.ps1`](../../../windows/git-ssh-signing/README.md).

## Problema

Assinar commits com a chave SSH protegida por senha faz o git pedir a senha **a cada
commit** quando a chave não está destravada em um agente SSH.

```
git commit  ->  ssh-keygen -Y sign  ->  ssh-agent (chave já destravada)
```

## Solução

O script [`enable-ssh-signing.sh`](./enable-ssh-signing.sh) faz, em ordem:

1. Corrige a permissão da chave privada para `600`, se estiver aberta demais (o ssh
   ignora a chave nesse caso).
2. Garante um agente SSH:
   - se `SSH_AUTH_SOCK` já aponta para um agente vivo (GNOME, KDE, etc.), usa ele;
   - senão liga o `ssh-agent` pelo systemd do usuário (`ssh-agent.socket`, ou uma
     `ssh-agent.service` criada em `~/.config/systemd/user` se a distro não trouxer a
     unit) e grava o `SSH_AUTH_SOCK` em `~/.config/environment.d/ssh-agent.conf`.
3. Testa uma assinatura pelo agente; se falhar, guarda a chave com `ssh-add` (pede a
   senha da chave uma vez).
4. Configura o git global:

   | Configuração | Valor |
   | --- | --- |
   | `gpg.format` | `ssh` |
   | `user.signingkey` | caminho da chave pública |
   | `commit.gpgsign` | `true` |
   | `gpg.ssh.allowedSignersFile` | `~/.ssh/allowed_signers` (para validar localmente) |

5. Copia a chave pública para a área de transferência (`wl-copy` ou `xclip`; sem eles,
   imprime no terminal).

Ele pula o que já estiver feito, então pode ser rodado de novo.

## Diferença para o Windows: depois de reiniciar

O agente do Windows grava a chave no disco. No Linux depende do agente:

| Agente | Depois do boot |
| --- | --- |
| Com chaveiro (GNOME `gcr-ssh-agent`, KDE com `ksshaskpass`) | Na primeira assinatura abre uma janela pedindo a senha; marque a opção de destravar automaticamente no login e ela não é mais pedida |
| `ssh-agent` puro (o que o script liga) | A chave fica só na memória: rode `ssh-add` uma vez após cada boot |

## Uso

Rode em um terminal interativo (a senha da chave é digitada nele):

```bash
# Chave padrão: ~/.ssh/id_ed25519
./enable-ssh-signing.sh

# Outra chave
./enable-ssh-signing.sh ~/.ssh/outra_chave
```

Depois, cadastre a chave no GitHub em
[Settings → SSH and GPG keys → New SSH key](https://github.com/settings/ssh/new) com
**Key type: Signing Key**.

> **Atenção:** mesmo que a chave já esteja no GitHub como *Authentication Key*, é preciso
> adicioná-la de novo como *Signing Key*. E o `user.email` do git precisa ser um e-mail
> verificado na conta, senão o commit aparece como "Unverified".

## Verificar se está funcionando

```bash
# Agente ativo e com a chave carregada
ssh-add -l

# Commit assinado sem pedir senha, e validado localmente
git commit --allow-empty -m "teste de assinatura"
git log --show-signature -1    # deve mostrar "Good "git" signature for <e-mail>"
```

## Desfazer

```bash
git config --global --unset commit.gpgsign
git config --global --unset gpg.format
git config --global --unset user.signingkey
git config --global --unset gpg.ssh.allowedSignersFile

# Tira a chave do agente
ssh-add -d ~/.ssh/id_ed25519

# Se o script ligou o ssh-agent do systemd
systemctl --user disable --now ssh-agent.socket ssh-agent.service
rm ~/.config/environment.d/ssh-agent.conf
```
