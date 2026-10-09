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
   - senão liga um pelo systemd do usuário, de preferência o `gcr-ssh-agent.socket`
     (o do chaveiro); sem ele, o `ssh-agent.socket`, ou uma `ssh-agent.service` criada
     em `~/.config/systemd/user` se a distro não trouxer a unit. O `SSH_AUTH_SOCK` vai
     para `~/.config/environment.d/ssh-agent.conf`.
3. Guarda a senha da chave no chaveiro do login (`secret-tool`), depois de conferir que
   ela abre a chave. Pede a senha **uma vez**, no terminal; se já houver uma senha
   errada salva, ela é substituída. A partir daí o agente destrava a chave sozinho a
   cada login, sem janela e sem `ssh-add`.
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

## Depois de reiniciar

Igual ao Windows: nada a fazer. O chaveiro do login abre junto com o login (PAM, via
GDM/SDDM com `pam_gnome_keyring`) e o `gcr-ssh-agent` busca a senha da chave nele.

Duas exceções:

- **Login automático (sem digitar a senha do usuário):** o chaveiro não abre sozinho e
  a primeira assinatura pede a senha do chaveiro.
- **Sem `gnome-keyring` + `gcr` + `secret-tool`:** o script cai no `ssh-agent` puro, que
  guarda a chave só na memória e precisa de `ssh-add` após cada boot. Ele avisa no fim.

## Se um commit ou o script travar

O `gcr-ssh-agent` não responde nunca mais quando a senha salva no chaveiro está errada
(por exemplo, digitada errada na janela do GNOME com "destravar automaticamente"
marcado). Rodar o script de novo corrige a senha salva; para soltar o que ficou preso:

```bash
systemctl --user restart gcr-ssh-agent.service
```

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
