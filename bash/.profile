test -z "$PROFILEREAD" && . /etc/profile || true

export EDITOR="emacsclient --create-frame --alternate-editor=''"
export VISUAL="emacsclient --create-frame --alternate-editor=''"
