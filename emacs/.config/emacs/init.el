;;; init.el -*- lexical-binding: t -*-

;;; Package mangement setup

;; Setup `package.el` & melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(unless package--initialized (package-initialize))

;; Setup `use-package.el`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setopt use-package-always-defer t)

;;; Customize write to seperate file

(setopt custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error-if-file-missing)


;;; Interface

;; Fonts
(defun mch/default-font-setup ()
  "Setup the default font"
  (if (getenv "WSLENV")
      (set-frame-font "IBM Plex Mono-15" nil t)
    (set-frame-font "IBM Plex Mono-13" nil t)))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (mch/default-font-setup))))
  (mch/default-font-setup))

;; Theme
(if (and (not (display-graphic-p)) (getenv "WSLENV"))
    (load-theme 'modus-vivendi nil nil)
  (load-theme 'modus-operandi-tinted nil nil))

;; Modeline

;; Remove borders from the modeline
(set-face-attribute 'mode-line nil :box nil)
(set-face-attribute 'mode-line-inactive nil :box nil)

(use-package minions
  ;; deal with minor-modes in the modeline
  :ensure t
  :hook (after-init . minions-mode))


;;; Some basic settings

(use-package emacs
  :ensure nil
  :config
  ;; setup the initial buffer - move to early-init.el?
  ;; (setopt initial-buffer-choice t)
  ;; (setopt initial-scratch-message nil)
  ;; disable some annoyances
  (setopt ring-bell-function 'ignore)
  (blink-cursor-mode -1)
  (setopt cursor-in-non-selected-windows nil)
  (setopt use-short-answers t)
  (setopt use-dialog-box nil)
  (setopt help-window-select t)
  ;; be modern, be posix
  (setopt sentence-end-double-space nil)
  (setopt require-final-newline t)
  (set-language-environment "UTF-8")
  ;; more readable buffer names
  (setopt uniquify-buffer-name-style 'forward)
  ;; backups, lockfiles & autosave
  (setopt make-backup-files nil)
  (setopt create-lockfiles nil)
  (setopt auto-save-include-big-deletions t)
  (setopt auto-save-no-message t)
  (defvar mch/tmp-dir (expand-file-name "tmp/" user-emacs-directory))
  (defvar mch/autosave-dir (expand-file-name "autosaves/" mch/tmp-dir))
  (dolist (d (list mch/tmp-dir mch/autosave-dir))
    (unless (file-directory-p d) (make-directory d t)))
  (setopt auto-save-file-name-transforms `((".*" ,mch/autosave-dir t))))

(use-package recentf
  :ensure nil
  :bind ("C-x C-r" . recentf-open)
  :hook (find-file . recentf-mode)
  :config
  (setopt recentf-max-saved-items 75)
  (setopt recentf-max-menu-tems 15)
  (setopt recentf-auto-cleanup 'never)
  (dolist (itm '("^/usr/share/emacs/\.*$" "~/.config/emacs/bookmarks"))
    (add-to-list 'recentf-exclude itm)))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package delsel
  ;; delete selection when entering new text over it
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package autorevert
  ;; listen to file changes outside emacs
  :ensure nil
  :hook (after-init . global-auto-revert-mode)
  :config
  (setopt auto-revert-verbose t))

(use-package server
  ;; run emacs instance as a server
  :ensure nil
  :demand t
  :config
  (setopt server-client-instructions nil)
  ;; but only run when no daemon or server running
  (unless (or (server-running-p) (daemonp))
    (server-start)))


;;; Minibuffer enhancements
;; TODO: embark
(use-package vertico
  ;; vertical minibuffer
  :ensure t
  :init
  (setopt context-menu-mode t)
  (setopt enable-recursive-minibuffers t)
  (setopt read-extended-command-predicate #'command-completion-default-include-p)
  (setopt minibuffer-prompt-properties
          '(read-only t cursor-intangible t face minibuffer-prompt))
  :hook (after-init . vertico-mode))

(use-package savehist
  ;; remember minibuffer history
  :ensure nil
  :hook (after-init . savehist-mode))

(use-package orderless
  ;; "fuzzy" completion
  :ensure t
  :demand t
  :config
  (setopt completion-styles '(orderless basic))
  (setopt completion-category-defaults nil)
  (setopt completion-category-overrides
          '((file (styles partial-completion))))
  (setopt completion-pcm-leading-wildcard t))

(use-package marginalia
  ;; add annotations to the minibuffer
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package consult
  :ensure t
  :bind
  ("C-x C-b" . consult-buffer)
  ("C-x r b" . consult-bookmark)
  ("C-x p b" . consult-project-buffer)
  ("M-g o" . consult-outline)
  :config
  (setopt consult-narrow-key "<"))

(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode)
  :config
  (setopt which-key-idle-delay 0.5))


;;; Navigation

;; Mouse
(use-package mouse
  :ensure nil
  :hook (after-init . mouse-wheel-mode)
  :config
  ;; behave like my window manager
  (setopt mouse-autoselect-window t)
  (setopt focus-follows-mouse t)
  (setopt mouse-drag-copy-region nil)
  (setopt make-pointer-invisible t)
  (setopt mouse-wheel-progressive-speed nil)
  (setopt mouse-wheel-follow-mouse t)
  (setopt scroll-preserve-screen-position t)
  (setopt scroll-conservatively 1)
  (setopt scroll-margin 6)
  (setopt hscroll-margin 8)
  (setopt next-screen-context-lines 6)
  (setopt mouse-yank-at-point t)
  (unless (display-graphic-p)
    (xterm-mouse-mode 1)))

;; Keybindings
(keymap-global-set "C-x b" 'ibuffer)

(defun mch/split-v-and-follow ()
  "split the view vertically and focus on the new split"
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(keymap-global-set "C-x 2" #'mch/split-v-and-follow)

(defun mch/split-h-and-follow ()
  "split the view horizontally and focus on the new split"
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(keymap-global-set "C-x 3" #'mch/split-h-and-follow)

;; half-page scrolling
(defun mch/scroll-half-page-down ()
  "scroll down half a page while keeping the cursor centered"
  (interactive)
  (let ((ln (line-number-at-pos (point)))
        (lmax (line-number-at-pos (point-max))))
    (cond ((= ln 1) (move-to-window-line nil))
          ((= ln lmax) (recenter (window-end)))
          (t (progn
               (move-to-window-line -1)
               (recenter))))))
(keymap-global-set "<next>" #'mch/scroll-half-page-down)

(defun mch/scroll-half-page-up ()
  "scroll up half a page while keeping the cursor centered"
  (interactive)
  (let ((ln (line-number-at-pos (point)))
        (lmax (line-number-at-pos (point-max))))
    (cond ((= ln 1) nil)
          ((= ln lmax) (move-to-window-line nil))
          (t (progn
               (move-to-window-line 0)
               (recenter))))))
(keymap-global-set "<prior>" #'mch/scroll-half-page-up)


;;; Programming

(defun mch/programming-setup ()
  "basic setup for programming"
  ;; set line numbers
  (setopt display-line-numbers-width 3)
  (setopt display-line-numbers-type 'relative)
  (display-line-numbers-mode 1)
  ;; use spaces not tabs
  (setopt indent-tabs-mode nil)
  (setopt tab-width 4)
  ;; fill column at 80 characters
  (setopt fill-column 80)
  (display-fill-column-indicator-mode t)
  ;; word-wrapping
  (setopt word-wrap t)
  (setopt truncate-lines t)
  (setopt truncate-partial-width-windows nil))
(add-hook 'prog-mode-hook #'mch/programming-setup)
(add-hook 'conf-mode-hook #'mch/programming-setup)

;; Syntax highlighting
(use-package treesit
  :ensure nil
  :config
  ;; less syntax highlighting in ts-modes
  (setopt treesit-font-lock-level 2))

;; Completion
(use-package corfu
  ;; simple completion framework
  :ensure t
  :bind (:map corfu-map
              ("C-n" . corfu-next)
              ("C-p" . corfu-previous)
              ("<escape>" . corfu-quit)
              ("<return>" . corfu-insert)
              ("M-d" . corfu-show-documentation)
              ("M-l" . corfu-show-location))
  :init
  (setopt tab-always-indent 'complete)
  (setopt text-mode-ispell-word-completion nil)
  (setopt read-extended-command-predicate #'command-completion-default-include-p)
  (global-corfu-mode)
  (corfu-history-mode t)
  (corfu-indexed-mode t)
  (corfu-popupinfo-mode t)
  (setopt corfu-auto-delay 0.0)
  (setopt corfu-auto-prefix 2)
  (setopt corfu-quit-no-match 'separator)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-separator ?\s)
  (corfu-quit-at-boundry nil)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  (corfu-scroll-margin 5)
  (completion-styles '(orderless basic)))

(use-package cape
  ;; completion at point
  :ensure t
  :defer t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

;; Code formatting
(use-package editorconfig
  ;; read formatting rules from editorconfig file
  :ensure nil
  :init
  (editorconfig-mode 1))

;; Version control
(use-package vc
  :ensure nil
  :init
  (setopt find-file-visit-truename t)
  (setopt find-file-suppress-same-file-warnings t)
  :config
  (setopt vc-follow-symlinks t))

;; LSP
(use-package eglot
  :ensure nil
  :defer t
  :hook ((python-ts-mode . eglot-ensure)
         (lua-ts-mode . eglot-ensure)
         (fennel-ts-mode . eglot-ensure))
  :config
  (setopt eglot-autoshutdown t)
  (setopt eglot-extend-to-xref t)
  :custom
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :documentFormattingProvider
     :documentRangeFormattingProvider
     :documentOnTyprFormattingProvider
     :colorProvider
     :foldingRangeProvider
     :inlayHintProvider)))

;; Python
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :config
  (add-to-list 'eglot-server-programs
               `(python-ts-mode
                 . ,(eglot-alternatives `(("basedpyright-langserver" "--stdio")
                                          ("ruff" "server")))))
  :init
  (add-hook 'python-ts-mode-hook (lambda () (set-fill-column 88))))

;; Lua
(use-package lua-ts-mode
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
               `(lua-ts-mode . ("lua-language-server")))
  :mode ("\\.lua\\'" . lua-ts-mode))

;; Fennel
(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fenel-mode)
  :config
  (add-to-list 'eglot-server-programs
               `(fennel-mode . ("fennel-ls")))
;; enable fennel in org-mode source blocks
  (with-eval-after-load 'org
    (require 'ob-fennel)))

;; Structural editing for lisps
(use-package paredit
  ;; parantheses, slurping & barfing
  :ensure t
  :hook ((emacs-lisp-mode . paredit-mode)
         (lisp-interaction-mode . paredit-mode)
         (fennel-mode . paredit-mode))
  :config
  (keymap-unset paredit-mode-map "M-s")
  (keymap-set paredit-mode-map "M-i" #'paredit-splice-sexp))


;;; Text editing

;; visual line mode in text-mode
(add-hook 'text-mode-hook #'visual-line-mode)

;; Org-mode
(use-package org
     :ensure nil
     :init
     (keymap-global-set "C-c l" #'org-store-link)
     (keymap-global-set "C-c a" #'org-agenda)
     (keymap-global-set "C-c c" #'org-capture)
     :hook (org-mode . (lambda () (electric-indent-mode -1)))
     :config
     (setopt org-direcotry (expand-file-name "~/Org"))
     (setopt org-default-notes-file (concat org-directory "/notes.org"))
     (setopt org-startup-folded 'content)
     (setopt org-startup-indented t)
     (setopt org-indent-mode-turn-on-hiding-stars nil)
     (setopt org-ellipsis " ▾"))

;; Markdown
(use-package markdown-mode
  ;; github flavored markdown for README.md files
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode))


;;; Modal editing
(use-package meow
  :ensure t
  :demand t
  :init
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore))
    (meow-define-keys
        'insert
      '("ESC" . meow-insert-exit))
    (meow-define-keys
        'normal
      '("/" . consult-line)
      ;; ignore round braces and double-quote
      '("(" . ignore)
      '(")" . ignore)
      '("\"" . ignore)))
  :config
  (meow-setup)
  (meow-global-mode))
