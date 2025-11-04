;;; mch-basic-settings.el -*- lexical-binding: t; -*-

;; disable bell sound
(setopt ring-bell-function 'ignore)

;; disable cursor blinking
(blink-cursor-mode -1)

;; do not use dialog boxes
(setopt use-dialog-box nil)

;; use y or n
(setopt use-short-answers t)

;; setup the initial buffer
(setopt initial-buffer-choice t)
(setopt initial-major-mode 'fundamental-mode)
(setopt initial-scratch-message nil)

;; auto update file when changed outside emacs
(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode)
  :config
  (setopt auto-revert-verbose t))

;; delete selection when entering text
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;; you are not a typewriter
(setopt sentence-end-double-space nil)

;; be posix. end files with a newline
(setopt require-final-newtline t)

;; UTF-8 as default. probably unneccessary
(set-language-environment "UTF-8")

;; allow emacsclient to connect to running sessions
(use-package server
  :ensure nil
  :config
  (setopt server-client-instructions nil)
  (unless (or (server-running-p) (daemonp))
    (server-start)))

(provide 'mch-basic-settings)
