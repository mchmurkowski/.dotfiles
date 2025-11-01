;;; sane-settings.el -*- lexical-binding: t; -*-

;; disable bell sound
(setopt ring-bell-function 'ignore)

;; setup the initial buffer
(setopt initial-buffer-choice t)
(setopt initial-major-mode 'fundamental-mode)
(setopt initial-scratch-message nil)

;; enable line numbers in prog and conf modes
(defun mch-work-with-code ()
  "Enable relative line numbers"
  (setopt display-line-numbers-width 3)
  (setopt display-line-numbers-type 'relative)
  (display-line-numbers-mode 1))

(add-hook 'prog-mode-hook #'mch-work-with-code)
(add-hook 'conf-mode-hook #'mch-work-with-code)

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
  (unless (or (server-running-p) (deamonp))
    (server-start)))

(provide 'sane-settings)
