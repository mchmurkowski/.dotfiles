test -z "$PROFILEREAD" && . /etc/profile || true

export EDITOR="emacsclient --no-window-system --alternate-editor=''"
export VISUAL="emacsclient --create-frame --alternate-editor=''"
