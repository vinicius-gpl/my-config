# Homebrew
/home/linuxbrew/.linuxbrew/bin/brew shellenv | source

if status is-interactive
    # Initial configs
    fastfetch
    set fish_greeting

    # ASDF configuration code
    if test -z $ASDF_DATA_DIR
        set _asdf_shims "$HOME/.asdf/shims"
    else
        set _asdf_shims "$ASDF_DATA_DIR/shims"
    end

    if not contains $_asdf_shims $PATH
        set -gx --prepend PATH $_asdf_shims
    end
    set --erase _asdf_shims
	 
    # Starship config
    starship init fish | source
	
    # Fzf config
    fzf --fish | source

    export FZF_DEFAULT_OPTS='--height 70% --tmux bottom,40% --layout reverse --border top'

    export FZF_CTRL_T_OPTS="
    --style full
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}' 
    --bind 'focus:transform-header:file 
    --brief {}'"   

    set -gx EDITOR nvim

    set -gx ANDROID_SDK_HOME /home/vinicius/Android/Sdk
    set -gx ANDROID_NDK_HOME /home/vinicius/Android/Sdk/ndk/27.0.12077973
end
