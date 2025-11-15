test -z "$PROFILEREAD" && . /etc/profile || true

export EDITOR="emacsclient --no-wait --reuse-frame --alternate-editor=''"
export VISUAL="emacsclient --no-wait --reuse-frame --alternate-editor=''"
