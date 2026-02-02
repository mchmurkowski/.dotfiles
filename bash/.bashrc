test -s ~/.alias && . ~/.alias || true

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ "$TERM" != "dumb" ]]; then
    eval "$(fzf --bash)"
    eval "$(starship init bash)"
fi

eval "$(zoxide init bash)"
