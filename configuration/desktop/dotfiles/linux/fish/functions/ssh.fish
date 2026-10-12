function ssh --wraps=ssh --description 'ssh via kitten quando estiver no Kitty'
    if test "$TERM" = xterm-kitty; and command -q kitten
        kitten ssh $argv
    else
        command ssh $argv
    end
end
