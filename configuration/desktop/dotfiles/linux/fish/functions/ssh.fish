function ssh --wraps=ssh --description 'ssh com TERM que o servidor remoto entende'
    if test "$TERM" != xterm-kitty
        command ssh $argv
    else if set -q ZELLIJ; or set -q TMUX; or not command -q kitten
        # Dentro de multiplexador o kitten ssh trava: ele espera uma resposta
        # do Kitty que o Zellij/tmux não repassa.
        TERM=xterm-256color command ssh $argv
    else
        kitten ssh $argv
    end
end
