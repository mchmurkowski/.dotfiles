;;; init.el -*- lexical-binding: t -*-

;;; Package management
;;;; Setup `package.el' & add the melpa archive
(progn (require 'package)
       (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
       (unless package--initialized (package-initialize)))

;;;; Setup `use-package.el'
(progn (unless (package-installed-p 'use-package)
         (package-refresh-contents)
         (package-install 'use-package))
       (require 'use-package)
       (setopt use-package-always-defer t))


;;; Run Emacs as server
(use-package server
  :ensure nil
  :demand t
  :config
  (setopt server-client-instructions nil)
  (unless (or (server-running-p) (daemonp))
    (server-start)))


;;; Interface
;;;; Fonts
(use-package faces
  :ensure nil
  :init
  (defun mch/setup-frame-font ()
    "Setup the default font and line spacing"
    (if (getenv "WSLENV")
        (set-frame-font "IBM Plex Mono-14" nil t)
      (set-frame-font "IBM Plex Mono-13" nil t))
    (set-face-attribute 'variable-pitch nil :family "IBM Plex Serif" :height 1.1)
    (set-face-attribute 'fixed-pitch nil :family "IBM Plex Mono")
    (setopt line-spacing 2))
  (setopt x-underline-at-descent-line t)
  (setopt truncate-string-ellipsis "…")
  ;; setup the default font for frames
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (with-selected-frame frame
                    (mch/setup-frame-font))))
    (mch/setup-frame-font)))

;;;; Theme
(cond ((and (display-graphic-p) (getenv "WSLENV"))
       (load-theme 'modus-operandi nil nil))
      ((and (not (display-graphic-p)) (getenv "WSLENV"))
       (load-theme 'modus-vivendi nil nil))
      (t (load-theme 'modus-operandi-tinted nil nil)))

;;;; Modeline
;; Remove borders from the modeline
(progn (set-face-attribute 'mode-line nil :box nil)
       (set-face-attribute 'mode-line-inactive nil :box nil)
       ;; Setup a minimal modeline
       (setopt mode-line-format '(" [%*] %b"
                                  mode-line-format-right-align
                                  "%l:%C | "
                                  mode-name
                                  "  ")))

(use-package hide-mode-line
  :ensure t
  :hook ((eshell-mode . hide-mode-line-mode)
         (eat-mode . hide-mode-line-mode)
         (vterm-mode . hide-mode-line-mode)
         (comint-mode . hide-mode-line-mode)))

;;;; Spacious padding
(use-package spacious-padding
  :ensure t
  :if window-system
  :hook (after-init . spacious-padding-mode))


;;; Some basic settings
(use-package emacs
  :ensure nil
  :init
  ;; keep `customize' from polluting my config file
  (setopt custom-file (expand-file-name "custom.el" user-emacs-directory))
  (load custom-file :no-error-if-file-missing)
  :config
  ;; setup the initial buffer
  (setopt initial-major-mode 'fundamental-mode
          initial-scratch-message nil)
  ;; no beeping and blinking
  (setopt visible-bell nil
          ring-bell-function 'ignore)
  (blink-cursor-mode -1)
  ;; short answers
  (setopt read-answer-short t
          confirm-kill-emacs 'y-or-n-p)
  (if (boundp 'use-short-answers)
      (setopt use-short-answers t)
    (advice-add 'yes-or-no-p :override #'y-or-n-p))
  ;; disable dialog boxes
  (setopt use-dialog-box nil
          use-file-dialog nil)
  ;; be modern, be posix
  (setopt sentence-end-double-space nil
          require-final-newline t)
  (set-language-environment "UTF-8")
  (setopt default-input-method nil))

(use-package files
  :ensure nil
  :init
  (let* ((tmp-dir (expand-file-name "tmp/" user-emacs-directory))
         (autosave-dir (expand-file-name "autosaves/" tmp-dir)))
    (dolist (d (list tmp-dir autosave-dir))
      (unless (file-directory-p d) (make-directory d t)))
    (setopt auto-save-file-name-transforms `((".*" ,autosave-dir t))))
  ;; do not make backup files nor lockfiles ...
  (setopt make-backup-files nil
          create-lockfiles nil)
  ;; ... and do not autosave, but provide sane settings
  (setopt auto-save-default nil
          auto-save-include-big-deletions t
          auto-save-no-message t)
  ;; symlinks
  (setopt find-file-visit-truename t
          find-file-suppress-same-file-warnings t)
  ;; read-only files should open in view-mode
  (setopt view-read-only t))

;; `ffap' stand for find-file-at-point
(use-package ffap
  :ensure nil
  :init
  (setopt ffap-machine-p-known 'reject))

(use-package autorevert
  ;; listen to file changes outside Emacs
  :ensure nil
  :hook (after-init . global-auto-revert-mode)
  :init
  (setopt auto-revert-interval 3)
  (setopt auto-revert-remote-files nil)
  (setopt auto-revert-use-notify t
          auto-revert-avoid-polling nil)
  (setopt auto-revert-verbose t)
  ;; also autorevert non-file buffers like dired buffers
  (setopt global-auto-revert-non-file-buffers t))

(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :config
  (dolist (itm '("^/usr/share/emacs/\.*$" "~/.config/emacs/bookmarks"))
    (add-to-list 'recentf-exclude itm))
  (setopt recentf-auto-cleanup
          (if (or (server-running-p) (daemonp)) 300 'never))
  (setopt recentf-max-saved-items 75)
  (setopt recentf-max-menu-items 15)
  ;; ensure that `recentf-cleanup' runs before `recentf-save-list'
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode)
  :init
  (setopt save-place-limit 400))

(use-package undo-fu-session
  :ensure t
  :hook (after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'")))

(use-package vundo
  :ensure t
  :commands (vundo vundo-mode))

(use-package dired
  :ensure nil
  :config
  (setopt dired-kill-when-opening-new-dired-buffer t)
  (setopt dired-listing-switches "-aGh --group-directories-first"))


;;; Minibuffer enhancements
(use-package vertico
  :ensure t
  :init
  (setopt enable-recursive-minibuffers t)
  (setopt read-extended-command-predicate #'command-completion-default-include-p)
  (setopt minibuffer-prompt-properties
          '(read-only t cursor-intangible t face minibuffer-prompt))
  :hook (after-init . vertico-mode))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :init
  (setopt history-length 300)
  (setopt savehist-autosave-interval 600))

(use-package orderless
  :ensure t
  :demand t
  :config
  (setopt completion-styles '(orderless basic))
  (setopt completion-category-defaults nil)
  (setopt completion-category-overrides
          '((file (styles partial-completion))))
  (setopt completion-pcm-leading-wildcard t))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package consult
  :ensure t
  :bind
  (("C-x b" . consult-buffer)
   ("C-x r b" . consult-bookmark)
   ("C-x p b" . consult-project-buffer)
   ("C-x C-r" . consult-recent-file)
   ("M-g o" . consult-outline)
   ("M-g i" . consult-imenu)
   ("M-g I" . consult-imenu-multi)
   ("M-s d" . consult-fd)
   ("M-s c" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ("M-s k" . consult-keep-lines)
   ("M-s u" . consult-focus-lines))
  :config
  (setopt consult-narrow-key "<"))

(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode)
  :config
  (setopt which-key-idle-delay 1.5
          which-key-idle-secondary-delay 0.25)
  (setopt which-key-add-column-padding 1)
  (setopt which-key-max-description-length 40))


;;; Navigation & behaviour

;;;; Buffers, windows & frames
(use-package uniquify
  :ensure nil
  :config
  (setopt uniquify-buffer-name-style 'forward)
  (setopt uniquify-after-kill-buffer-p t))

(use-package ibuffer
  :ensure nil
  :bind
  ("C-x C-b" . ibuffer))

(use-package window
  :ensure nil
  :init
  ;; behave like my window manager
  (setopt mouse-autoselect-window t
          mouse-wheel-follow-mouse t)
  (setopt focus-follows-mouse t)
  (setopt cursor-in-non-selected-windows nil
          highlight-nonselected-windows nil)
  ;; prefer horizontal splits with wide windows
  (setopt split-width-threshold 80)
  ;; prefer vertical splits with long or narrow windows
  (setopt split-height-threshold 40)
  ;; better behaviour for manual splits
  (setopt help-window-select t)
  (setopt window-combination-resize t)
  (defadvice split-window (after split-window-after activate)
    (select-window (get-lru-window))))

(use-package winner
  :ensure nil
  :hook (after-init . winner-mode)
  :bind (("C-x 1" . #'toggle-delete-other-windows)
         ("C-c w u" . winner-undo)
         ("C-c w U" . winner-redo)
         (:repeat-map mch/winner-repeat-map
                      ("u" . winner-undo)
                      ("U" . winner-redo)))
  :preface
  (defun toggle-delete-other-windows ()
    "Delete other windows in frame if any, or restore previous window config."
    (interactive)
    (if (and winner-mode
             (equal (selected-window) (next-window)))
        (winner-undo)
      (delete-other-windows)))
  :init
  (setopt winner-dont-bind-my-keys t))

(use-package windmove
  :ensure nil
  :bind (("C-c w h" . windmove-left)
         ("C-c w j" . windmove-down)
         ("C-c w k" . windmove-up)
         ("C-c w l" . windmove-right)
         ("C-c w H" . windmove-swap-states-left)
         ("C-c w J" . windmove-swap-states-down)
         ("C-c w K" . windmove-swap-states-up)
         ("C-c w L" . windmove-swap-states-right)
         ("C-c w M-h" . windmove-delete-left)
         ("C-c w M-j" . windmove-delete-down)
         ("C-c w M-k" . windmove-delete-up)
         ("C-c w M-l" . windmove-delete-right)
         (:repeat-map mch/windmove-repeat-map
                      ("h" . windmove-left)
                      ("j" . windmove-down)
                      ("k" . windmove-up)
                      ("l" . windmove-right)
                      ("H" . windmove-swap-states-left)
                      ("J" . windmove-swap-states-down)
                      ("K" . windmove-swap-states-up)
                      ("L" . windmove-swap-states-right)
                      ("M-h" . windmove-delete-left)
                      ("M-j" . windmove-delete-down)
                      ("M-k" . windmove-delete-up)
                      ("M-l" . windmove-delete-right)))
  :config
  (setopt windmove-wrap-around t))

;;; TODO: Popup management: look into popper.el and shackle.el

(use-package pulse
  ;; lifted from https://karthinks.com/software/batteries-included-with-emacs/
  :ensure nil
  :init
  (defun mch/pulse-line (&rest _)
    "Pulse the current line."
    (pulse-momentary-highlight-one-line (point)))
  (dolist (command '(backward-page forward-page other-window))
    (advice-add command :after #'mch/pulse-line)))

;;;; Keyboard
(use-package repeat
  :ensure nil
  :hook (after-init . repeat-mode))

;;; Keybindings
(use-package personal-keybindings
  :ensure nil
  :bind (([remap kill-buffer] . kill-current-buffer)
         ([remap capitalize-word] . capitalize-dwim) ; M-c works on regions
         ([remap upcase-word] . upcase-dwim)         ; M-u works on regions
         ([remap downcase-word] . downcase-dwim))    ; M-l works on regions
  :init
  ;; lifted from: https://emacsredux.com/blog/2025/06/01/let-s-make-keyboard-quit-smarter/
  (defun mch/keyboard-quit-dwim ()
    "Smarter version of the built-in `keyboard-quit'"
    (interactive)
    (if (active-minibuffer-window)
        (if (minibufferp)
            (minibuffer-keyboard-quit)
          (abort-recursive-edit))
      (keyboard-quit)))
  (defun mch/scroll-half-page-down ()
    "Scroll down half a page while keeping the cursor centred."
    (interactive)
    (let ((ln (line-number-at-pos (point)))
          (lmax (line-number-at-pos (point-max))))
      (cond ((= ln 1) (move-to-window-line nil))
            ((= ln lmax) (recenter (window-end)))
            (t (progn
                 (move-to-window-line -1)
                 (recenter))))))
  (defun mch/scroll-half-page-up ()
    "Scroll up half a page while keeping the cursor centred."
    (interactive)
    (let ((ln (line-number-at-pos (point)))
          (lmax (line-number-at-pos (point-max))))
      (cond ((= ln 1) nil)
            ((= ln lmax) (move-to-window-line nil))
            (t (progn
                 (move-to-window-line 0)
                 (recenter))))))
  ;; keyboard-quit do what I mean
  (global-set-key [remap keyboard-quit] #'mch/keyboard-quit-dwim)
  ;; half page scrolling
  (keymap-global-set "<next>" #'mch/scroll-half-page-down)
  (keymap-global-set "<prior>" #'mch/scroll-half-page-up))

;;;; Mouse
(use-package mouse
  :ensure nil
  :hook (after-init . mouse-wheel-mode)
  :init
  (setopt mouse-drag-copy-region nil)
  (setopt make-pointer-invisible t)
  (setopt mouse-wheel-progressive-speed nil)
  (setopt fast-but-imprecise-scrolling t)
  (setopt scroll-preserve-screen-position t)
  (setopt scroll-conservatively 101)
  (setopt scroll-margin 6)
  (setopt hscroll-margin 8)
  (setopt next-screen-context-lines 6)
  (setopt mouse-yank-at-point t)
  (when (display-graphic-p)
    (setopt context-menu-mode t))
  (unless (display-graphic-p)
    (xterm-mouse-mode 1)))


;;; Search
(use-package isearch
  :ensure nil
  :init
  (add-hook 'isearch-mode-end-hook #'recenter)
  :config
  (setopt isearch-lazy-count t
          lazy-count-prefix-format "(%s/%s) "))

(use-package re-builder
  :ensure nil
  :hook (after-init . (lambda () (minibuffer-regexp-mode 1)))
  :config
  (setopt reb-re-syntax 'string))

(use-package xref
  :ensure nil
  :config
  (setopt xref-search-program 'ripgrep))


;;; Programming
(use-package prog-mode
  :ensure nil
  :no-require t
  :init
  (defun mch/programming-setup ()
    "Basic settings for programming."
    ;; set line numbers
    (setopt display-line-numbers-width 4
            display-line-numbers-widen t
            display-line-numbers-type 'relative)
    (display-line-numbers-mode 1)
    ;; use spaces not tabs
    (setopt indent-tabs-mode nil
            tab-width 4)
    ;; fill column at 80 characters
    (setopt fill-column 80)
    (display-fill-column-indicator-mode t)
    ;; word-wrapping
    (setopt word-wrap t)
    (setopt truncate-lines t
            truncate-partial-width-windows 70))
  :config
  (dolist (hooks '(prog-mode-hook conf-mode-hook))
    (add-hook hooks #'mch/programming-setup)))

;;;; Syntax highlighting
(use-package treesit
  :ensure nil
  :init
  (setopt redisplay-skip-fontification-on-input t)
  :config
  (setopt treesit-language-source-alist
          `((lua "https://github.com/tree-sitter-grammars/tree-sitter-lua.git")))
  ;; less syntax highlighting in ts-modes
  (setopt treesit-font-lock-level 2))

;;;; Completion
(use-package corfu
  ;; simple completion framework
  :ensure t
  :hook ((prog-mode . corfu-mode)
         (conf-mode . corfu-mode))
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
  (setopt completion-ignore-case t)
  :config
  (corfu-history-mode t)
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

;;;; Code formatting
(use-package editorconfig
  :ensure nil
  :hook ((prog-mode . editorconfig-mode)
         (conf-mode . editorconfig-mode)))

(use-package indent
  :ensure nil
  :init
  (defun mch/indent-buffer ()
    "Indent the entire buffer."
    (interactive)
    (indent-region (point-min) (point-max))))

(use-package whitespace
  :ensure nil
  :hook (before-save-hook . whitespace-cleanup))

;;;; REPLs, shells & terminals
(use-package compile
  :ensure nil
  :config
  (setopt compilation-scroll-output 'first-error)
  (setopt compilation-skip-threshold 2)
  ;; close the window containing the compilation buffer on success
  ;; lifted from: https://emacsredux.com/blog/2026/03/06/mastering-compilation-mode/
  (setopt compilation-finish-functions
          (list (lambda (buf status)
                  (when (string-match-p "finished" status)
                    (run-at-time 1 nil #'delete-windows-on buf))))))

(use-package eshell
  :ensure nil
  :hook ((eshell-mode . completion-preview-mode)
         (eshell-mode . visual-line-mode))
  :init
  (setopt eshell-banner-message "")
  (setopt eshell-prompt-function
          (lambda ()
            (concat "\n" (abbreviate-file-name (eshell/pwd))
                    (unless (eshell-exit-success-p)
                      (format "[%d]" eshell-last-command-status))
                    (if (= (file-user-uid) 0) " # " " λ "))))
  :config
  ;; lifted from https://tony-zorman.com/posts/emacs-potpourri.html#integrating-zoxide-with-eshell
  (advice-add 'eshell/cd :around
              (lambda (cd &rest args)
                "On directory change, add the path to zoxide's database."
                (let ((old-path (eshell/pwd))
                      (_ (apply cd args))
                      (new-path (eshell/pwd)))
                  (when (and old-path new-path (not (string= old-path new-path)))
                    (shell-command-to-string (concat "zoxide add " new-path))))))
  (defun eshell/z (dir)
    "Navigate to a previously visited directory."
    (eshell/cd
     (string-trim (shell-command-to-string (concat "zoxide query " dir))))
    (eshell/ls))
  (defun eshell/e (file)
    (find-file file))
  (defun eshell/ff (file)
    (find-file file))
  (defun eshell/fo (file)
    (find-file-other-window file))
  (defalias 'eshell/clear 'eshell/clear-scrollback))

(use-package eat
  :ensure t
  :hook ((eat-mode . completion-preview-mode)
         (eshell-load . eat-eshell-mode))
  :init
  (setopt eshell-visual-commands nil)
  :config
  (setopt eat-kill-buffer-on-exit t))

(use-package vterm
  :ensure t
  :if window-system
  :commands (vterm vterm-other-window))

;;;; Version control
(use-package vc
  :ensure nil
  :config
  (setopt vc-follow-symlinks t))

(use-package magit
  ;; a git porcelain inside Emacs
  :ensure t
  :commands (magit-status magit-log)
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch))
  :config
  (setopt git-commit-summary-max-length 50)
  (setopt git-commit-fill-column 72))

;;;; LSP
(use-package eglot
  :ensure nil
  :defer t
  :hook ((python-ts-mode . eglot-ensure)
         (lua-ts-mode . eglot-ensure)
         (fennel-mode . eglot-ensure))
  :init
  (setopt xref-show-xrefs-function #'consult-xref)
  (setopt xref-show-definitions-function #'consult-xref)
  :config
  (setopt eglot-sync-connect 0)
  (setopt eglot-autoshutdown t)
  (setopt eglot-extend-to-xref t)
  (setopt jsonrpc-event-hook nil)
  (setopt eglot-events-buffer-config '(:size 0 :format short))
  :custom
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :documentFormattingProvider
     :documentRangeFormattingProvider
     :documentOnTypeFormattingProvider
     :colorProvider
     :foldingRangeProvider
     :inlayHintProvider)))

;;;; Python
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 `(python-ts-mode
                   . ,(eglot-alternatives `(("basedpyright-langserver" "--stdio")
                                            ("ruff" "server"))))))
  :init
  (add-hook 'python-ts-mode-hook (lambda () (set-fill-column 88))))

(use-package hy-mode
  :ensure t
  :mode ("\\.hy\\'" . hy-mode))

(use-package uv-mode
  :ensure t
  :hook ((python-ts-mode . uv-mode-auto-activate-hook)
         (hy-mode . uv-mode-auto-activate-hook)))

;;;; Lua
(use-package lua-ts-mode
  :ensure nil
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 `(lua-ts-mode . ("lua-language-server"))))
  :mode ("\\.lua\\'" . lua-ts-mode))

;;;; Common Lisp
(use-package sly
  :ensure t
  :hook ((sly-mrepl-mode . paredit-mode)
         (sly-mrepl-mode . corfu-mode))
  :config
  (setopt inferior-lisp-program "sbcl"))

;;;; Fennel
(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fennel-mode)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 `(fennel-mode . ("fennel-ls"))))
  ;; enable fennel in org-mode source blocks
  (with-eval-after-load 'org
    (require 'ob-fennel)))

;;;; Outline minor mode when editing Emacs lisp
(use-package outline
  ;; NOTE: look into hs-minor-mode
  :ensure nil
  :hook ((emacs-lisp-mode . outline-minor-mode)
         ;; lifted from: https://github.com/jamescherti/minimal-emacs.d?tab=readme-ov-file#outline-minor-mode-and-hs-minor-mode
         (outline-minor-mode . (lambda ()
                                 (let* ((display-table (or buffer-display-table (make-display-table)))
                                        (face-offset (* (face-id 'shadow) (ash 1 22)))
                                        (value (vconcat (mapcar (lambda (c) (+ face-offset c)) " ⏷"))))
                                   (set-display-table-slot display-table 'selective-display value)
                                   (setopt buffer-display-table display-table)))))
  :bind (:map outline-minor-mode-map
              ("C-<tab>" . outline-cycle)
              ("<backtab>" . outline-cycle-buffer)))

;;;; Structural editing for lisps
(use-package paredit
  ;; parentheses, slurping & barfing
  :ensure t
  :hook ((emacs-lisp-mode . paredit-mode)
         (lisp-mode . paredit-mode)
         (lisp-interaction-mode . paredit-mode)
         (hy-mode . paredit-mode)
         (fennel-mode . paredit-mode))
  :config
  (keymap-unset paredit-mode-map "RET")
  (keymap-unset paredit-mode-map "M-s")
  (keymap-set paredit-mode-map "M-D" #'paredit-splice-sexp)
  (keymap-unset paredit-mode-map "M-?"))

;;; Better automatic indentation when typing and editing lisping
(use-package aggressive-indent
  :ensure t
  :hook ((emacs-lisp-mode . aggressive-indent-mode)
         (lisp-interaction-mode . aggresive-indent-mode)
         (hy-mode . aggresive-indent-mode)
         (fennel-mode . aggresive-indent-mode)))


;;; Text editing
;; visual line mode in text-mode
(use-package text-mode
  :ensure nil
  :no-require t
  :hook (text-mode . visual-line-mode))

(use-package delsel
  ;; delete selection when entering new text over it
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package mixed-pitch
  :ensure t
  :if window-system
  :hook ((org-mode . mixed-pitch-mode)
         (markdown-mode . mixed-pitch-mode)))

(use-package olivetti
  :ensure t
  :if window-system
  :hook ((org-mode . olivetti-mode)
         (markdown-mode . olivetti-mode))
  :init
  (setq olivetti-minimum-body-width 40)
  (setq olivetti-body-width 66))

;;;; Expanding text selection
(use-package expreg
  :ensure t
  :after (hel)
  :bind (:map hel-normal-state-map
              ("C-=" . expreg-expand)   ; Alt-o in Helix
              ("C--" . expreg-contract) ; Alt-i in Helix
              (:repeat-map mch/expreg-repeat-map
                           ("=" . expreg-expand)
                           ("-" . expreg-contract)
                           :exit
                           ("<control-bracketleft>" . ignore))))

;;;; Spell-checking
(use-package ispell
  :ensure nil
  :init
  (defun mch/ispell-change-dictionary-pl ()
    "Use Polish dictionary for this buffer."
    (interactive)
    (setopt ispell-local-dictionary "pl"))
  (defun mch/ispell-change-dictionary-en ()
    "Use British English dictionary for this buffer"
    (interactive)
    (setopt ispell-local-dictionary "en_GB"))
  (setopt ispell-program-name "aspell")
  (setopt ispell-dictionary "en_GB")
  :config
  (ispell-set-spellchecker-params))

(use-package flyspell
  :ensure nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

;;;; Org-mode
(use-package org
  :ensure nil
  :init
  (keymap-global-set "C-c l" #'org-store-link)
  (keymap-global-set "C-c a" #'org-agenda)
  (keymap-global-set "C-c c" #'org-capture)
  :hook (org-mode . (lambda () (electric-indent-mode -1)))
  :config
  (setopt org-directory (expand-file-name "~/Org"))
  (setopt org-default-notes-file (concat org-directory "/notes.org"))
  (setopt org-startup-folded 'content)
  (setopt org-startup-indented t)
  (setopt org-indent-mode-turn-on-hiding-stars nil)
  (setopt org-hide-emphasis-markers t)
  (setopt org-ellipsis " ⏷"))

(use-package ox-typst
  :ensure t
  :after org)

;;;; Markdown
(use-package markdown-mode
  ;; GitHub flavoured markdown for README.md files
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode))


;;; Modal editing
(use-package hel
  :ensure t
  :if window-system ; currently, quitting insert mode in terminal does not work
  :demand t
  :vc (:url "https://github.com/anuvyklack/hel.git" :rev "main")
  :hook ((after-init . hel-mode)
         (after-save . hel-normal-state))
  :init
  (use-package dash :ensure t)
  (use-package avy :ensure t)
  (use-package pcre2el :ensure t)
  ;; unshackle C-[ from the escape key
  (let ((frame (framep (selected-frame))))
    (or (eq t frame)
        (eq 'pc frame)
        (define-key input-decode-map
                    (kbd "C-[")
                    [control-bracketleft])))
  (setopt hel-want-C-hjkl-keys nil)
  (keymap-global-unset "C-s")
  :config
  (dolist (state '(normal insert motion))
    (hel-keymap-global-set :state state
      ;; restore ESC to its rightful place
      "<escape>" nil
      ;; restore the universal argument to its rightful place
      "C-u" 'universal-argument
      "M-u" 'upcase-dwim
      ;; restore delete-char
      "C-d" 'delete-char
      ;; use isearch for search
      "C-f" 'isearch-forward
      "C-b" 'isearch-backward)
    ;; make isearch repeat with new bindings
    (keymap-set isearch-mode-map "C-f" 'isearch-repeat-forward)
    (keymap-set isearch-mode-map "C-b" 'isearch-repeat-backward))
  (hel-keymap-global-set :state 'insert
    "<control-bracketleft>" 'hel-normal-state)
  (keymap-unset hel-normal-state-map "C-w" 'remove)
  (keymap-unset hel-motion-state-map "C-w" 'remove)
  (hel-keymap-global-set :state 'normal
    "<control-bracketleft>" 'hel-normal-state-escape
    "M-s" nil
    "C-s" 'hel-split-region-on-newline
    "/" 'consult-line
    "z z" 'recenter)
  (dolist (mode '(text-mode shell-mode eshell-mode eat-mode vterm-mode comint-mode vc-git-log-edit-mode))
    (hel-set-initial-state mode 'insert)))
