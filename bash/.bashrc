test -s ~/.alias && . ~/.alias || true

if [[ "$INSIDE_EMACS" = 'vterm' ]] \
    && [[ -n ${EMACS_VTERM_PATH} ]] \
    && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
	source ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
fi

if [[ "$TERM" != "dumb" ]]; then
    eval "$(fzf --bash)"
    eval "$(starship init bash)"
fi

eval "$(zoxide init bash)"
