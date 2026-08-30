;;; init.el -*- lexical-binding: t -*-

;;; Motto
;; "One does not simply share his Emacs configuration. This is all
;; personalised to my quirks and misdemeanours." ~ Emerald McS. et al.,
;; PhD - Emacs User @ University of Texas Instruments


;;; Package management
;;;; Setup `package.el', add melpa & setup `use-package.el'
(progn (require 'package)
       (add-to-list 'package-archives
                    '("melpa" . "https://releases.melpa.org/packages/") t)
       (unless package--initialized (package-initialize))
       (unless (package-installed-p 'use-package)
         (package-refresh-contents)
         (package-install 'use-package))
       (require 'use-package)
       (setq use-package-always-defer t))


;;; Interface
;;;; Fonts
(use-package faces
  :ensure nil
  :init
  (defun mch/setup-frame-font ()
    "Setup the default font and line spacing."
    (if (getenv "WSLENV")
        (set-frame-font "IBM Plex Mono-14" nil t)
      (set-frame-font "IBM Plex Mono-13" nil t))
    (set-face-attribute 'variable-pitch nil :family "IBM Plex Serif" :height 1.1)
    (set-face-attribute 'fixed-pitch nil :family "IBM Plex Mono")
    (setq line-spacing 2))
  (setq x-underline-at-descent-line t)
  (setq truncate-string-ellipsis "…")
  ;; setup the default font for frames
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (with-selected-frame frame
                    (mch/setup-frame-font))))
    (mch/setup-frame-font)))

;;;; Theme
(use-package modus-themes
  :ensure nil ; use the built-in version
  :demand t
  :init
  (require-theme 'modus-themes)
  :config
  (if (display-graphic-p)
      (modus-themes-load-theme 'modus-operandi)
    (modus-themes-load-theme 'modus-vivendi)))

;;;; Modeline
(use-package spacious-padding
  :ensure t
  :if window-system
  :hook (after-init . spacious-padding-mode))


;;; Basic `emacs' settings
(use-package emacs
  :ensure nil
  :preface
  (defun mch/keyboard-quit-dwim ()
    "Smarter version of the built-in `keyboard-quit'.

Lifted from: https://emacsredux.com/blog/2025/06/01/let-s-make-keyboard-quit-smarter/."
    (interactive)
    (if (active-minibuffer-window)
        (if (minibufferp)
            (minibuffer-keyboard-quit)
          (abort-recursive-edit))
      (keyboard-quit)))
  (defun mch/narrow-or-widen-dwim (p)
    "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first. Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed. Lifted from: https://endlessparentheses.com/emacs-narrow-or-widen-dwim.html"
    (interactive "P")
    (declare (interactive-only))
    (cond ((and (buffer-narrowed-p) (not p)) (widen))
          ((region-active-p)
           (narrow-to-region (region-beginning)
                             (region-end)))
          ((derived-mode-p 'org-mode)
           (cond ((ignore-errors (org-edit-src-code) t)
                  (delete-other-windows))
                 ((ignore-errors (org-narrow-to-block) t))
                 (t (org-narrow-to-subtree))))
          ((derived-mode-p 'latex-mode)
           (LaTeX-narrow-to-environment))
          (t (narrow-to-defun))))
  :bind (([remap keyboard-quit] . mch/keyboard-quit-dwim)
         ([remap kill-buffer] . kill-current-buffer)
         ([remap capitalize-word] . capitalize-dwim) ; M-c works on regions
         ([remap upcase-word] . upcase-dwim)         ; M-u works on regions
         ([remap downcase-word] . downcase-dwim)     ; M-l works on regions
         ([remap list-buffers] . ibuffer)
         ("M-o" . other-window)
         ([remap zap-to-char] . zap-up-to-char)
         ("M-Z" . zap-to-char)
         ("C-x n" . mch/narrow-or-widen-dwim))
  :init
  ;; keep `customize' from polluting my config file
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (load custom-file :no-error-if-file-missing)
  :config
  ;; setup the initial buffer
  (setq initial-major-mode 'fundamental-mode
        initial-scratch-message nil)
  ;; no beeping and blinking
  (setq visible-bell nil
        ring-bell-function 'ignore)
  (blink-cursor-mode -1)
  (setq blink-cursor-delay 0.3
        blink-cursor-interval 0.7)
  (setq-default cursor-type 'bar)
  ;; don't display the cursor or show highlighted text in non-active windows
  (setq cursor-in-non-selected-windows nil
        highlight-nonselected-windows nil)
  ;; short answers
  (setq read-answer-short t
        confirm-kill-emacs 'y-or-n-p)
  (if (boundp 'use-short-answers)
      (setq use-short-answers t)
    (advice-add 'yes-or-no-p :override #'y-or-n-p))
  ;; disable dialog boxes
  (setq use-dialog-box nil
        use-file-dialog nil)
  ;; be modern, be posix
  (setq sentence-end-double-space nil
        require-final-newline t)
  (set-language-environment "UTF-8")
  (setq default-input-method nil)
  ;; disable pinging things that look like urls
  (setq ffap-machine-p-known 'reject)
  ;; do not create backup files, lockfiles and auto-saves
  (setq make-backup-files nil
        create-lockfiles nil)
  (setq auto-save-default nil)
  ;; do not ask, just follow symlinks
  (setq vc-follow-symlinks t)
  (setq find-file-visit-truname t
        find-file-supress-same-file-warnings t)
  ;; read-only files should should open in view-mode
  (setq view-read-only t)
  ;; uniquify buffer name
  (setq uniquify-buffer-name-style 'forward
        uniquify-after-kill-buffer-p t)
  ;; enable delete-selection-mode
  (delete-selection-mode 1)
  ;; save clipboard before replacing
  (setq save-interprogram-paste-before-kill t)
  ;; better split and window behaviour
  (setq split-width-threshold 88
        split-height-threshold nil)
  (setq window-combination-resize t)
  (setq help-window-select t)
  (defadvice split-window (after split-window-after activate)
    (select-window (get-lru-window)))
  ;; scroll and mouse settings
  (setq mouse-drag-copy-region nil)
  (setq make-pointer-invisible t)
  (setq mouse-wheel-progressive-speed nil)
  (setq fast-but-imprecise-scrolling t)
  (setq scroll-preserve-screen-position t)
  (setq scroll-conservatively 101)
  (setq scroll-margin 4)
  (setq hscroll-margin 6)
  (setq next-screen-context-lines 4)
  (setq mouse-yank-at-point t)
  (if (not (display-graphic-p))
      (xterm-mouse-mode 1)
    (setq context-menu-mode t))
  (dolist (cmd '(narrow-to-region narrow-to-page
                                  upcase-region downcase-region))
    (put cmd 'disabled nil)))

;;;; Setup nice-to-have built-ins
(use-package repeat
  :ensure nil
  :hook (after-init . repeat-mode)
  :config
  (setq set-mark-command-repeat-pop t))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 300)
  (setq savehist-autosave-interval 600))

(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :bind (([remap find-file-read-only] . recentf-open))
  :config
  (setq recentf-auto-cleanup (if (daemonp) 300 'never))
  (setq recentf-exclude
        (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
              "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
              "\\.7z$" "\\.rar$"
              "COMMIT_EDITMSG\\'"
              "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
              "-autoloads\\.el$" "autoload\\.el$"))
  (setq recentf-max-saved-items 50
        recentf-max-menu-items 15)
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode)
  :config
  (setq save-place-limit 300))

(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode)
  :config
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t
        auto-revert-avoid-polling nil)
  (setq auto-revert-verbose t))


;;; Minibuffer enhancements
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :init
  (setq enable-recursive-minibuffers t)
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package consult
  :ensure t
  :bind (("C-c h" . consult-history)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ([remap switch-to-buffer] . consult-buffer)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap switch-buffer-other-window] . consult-buffer-other-window)
         ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap yank-pop] . consult-yank-pop)
         ([remap imenu] . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ([remap goto-line] . consult-goto-line)
         ("M-g o" . consult-outline-dwim)
         ;; search-map
         ("M-s f" . consult-fd)
         ("M-s g" . consult-ripgrep)
         ("M-s G" . consult-git-grep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi))
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (defun consult-outline-dwim (arg)
    (interactive "P")
    (if arg
        (consult-outline)
      (if (derived-mode-p 'org-mode)
          (consult-org-heading)
        (consult-outline))))
  (setq consult-narrow-key "<"))


;;; Dired
(use-package dired
  :ensure nil
  :init
  (setq global-auto-revert-non-file-buffers t)
  :config
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-listing-switches "-aGh --group-directories-first"))


;;; Shells, terminals & REPLs
(use-package eat
  :ensure t
  :hook (eshell-load . eat-eshell-mode)
  :init
  (setq eshell-visual-commands nil)
  :config
  (setq eat-kill-buffer-on-exit t))


;;; Text search, navigation & selection
(use-package isearch
  :ensure nil
  :hook (isearch-mode-end . recenter)
  :config
  (setq isearch-lazy-count t
        lazy-count-prefix-format "(%s/%s) "))

(use-package avy
  :ensure t
  :bind ("C-'" . avy-goto-char-2)
  :config
  (eval-after-load "isearch"
    '(define-key isearch-mode-map (kbd "C-'") 'avy-isearch))
  (global-set-key (kbd "C-c C-j") 'avy-resume))

(use-package expreg
  :ensure t
  :bind (("C-=" . expreg-expand)
         ("C--" . expreg-contract)
         (:repeat-map mch/expreg-repeat-map
                      ("=" . expreg-expand)
                      ("-" . expreg-contract))))

(use-package iedit
  :ensure t
  :demand t
  :preface
  (defun mch/iedit-dwim (arg)
    "Starts iedit but uses narrow-to-defun to limit its scope.

Lifted from: https://www.masteringemacs.org/article/iedit-interactive-multi-occurrence-editing-in-your-buffer"
    (interactive "P")
    (if arg
        (iedit-mode)
      (save-excursion
        (save-restriction
          (widen)
          (if iedit-mode
              (iedit-done)
            (narrow-to-defun)
            (iedit-start (current-word) (point-min) (point-max)))))))
  :bind (("C-;" . mch/iedit-dwim)
         ("M-s i" . iedit-mode-from-isearch)))

;;;; Undoing
(use-package undo-fu-session
  :ensure t
  :bind (("C-/" . undo-only)
         ("C-?" . redo-only))
  :hook (after-init . undo-fu-session-global-mode)
  :init
  (setq undo-limit 256000
        undo-strong-limit 2000000
        undo-outer-limit 36000000)
  :config
  (when (executable-find "zstd")
    (setq undo-fu-session-compression 'zst))
  (setopt undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'")))

(use-package vundo
  :ensure t
  :commands (vudo-popup-mode)
  :bind ("C-x u" . vundo)
  :config
  (setopt vundu-glyph-alist vundo-unicode-symbols))


;;; Programming
(define-minor-mode mch/prog-mode
  "Minor mode that holds my preferred settings for working with code."
  :init-value nil
  :global nil
  (if mch/prog-mode
      (progn
        (setq-local display-line-numbers-width 4
                    display-line-numbers-widen t
                    display-line-numbers-type 'relative)
        (display-line-numbers-mode 1)
        ;; use spaces not tabs
        (setq-local indent-tabs-mode nil
                    tab-width 4)
        ;; tab completes
        (setq-local tab-always-indent 'complete)
        ;; fill column at 80 characters
        (setq-local fill-column 80)
        (display-fill-column-indicator-mode 1)
        ;; word-wrapping
        (setq-local word-wrap t)
        (setq-local truncate-lines t
                    truncate-partial-width-windows 70))
    (dolist (var `(display-line-numbers-width display-line-numbers-widen display-line-numbers-type
                                              indent-tabs-mode tab-width tab-always-indent fill-column
                                              word-wrap truncate-lines truncate-partial-width-windows))
      (kill-local-variable var))
    (display-line-numbers-mode -1)
    (display-fill-column-indicator-mode -1)))

(dolist (hooks '(prog-mode-hook conf-mode-hook))
  (add-hook hooks (lambda () (mch/prog-mode 1))))

;;;; Completions
(use-package orderless
  :ensure t
  :demand t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion))))
  (setq completion-pcm-leading-wildcard t))

(use-package corfu
  :ensure t
  :hook ((prog-mode . corfu-mode)
         (conf-mode . corfu-mode))
  :init
  (setq tab-always-indent 'complete)
  (setq completion-ignore-case t)
  :config
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)
  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1)
  (setq corfu-auto t
        corfu-auto-delay 0.5
        corfu-auto-prefix 3)
  (keymap-unset corfu-map "RET")
  (setq corfu-count 9
        corfu-scroll-margin 2
        corfu-cycle t)
  (define-key corfu-map (kbd "<tab>") #'corfu-complete)
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package cape
  :ensure t
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-mode)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;;;; Code formatting
(use-package editorconfig
  :ensure nil
  :hook ((prog-mode . editorconfig-mode)
         (conf-mode . editorconfig-mode)))

(use-package whitespace
  :ensure nil
  :hook (before-save . whitespace-cleanup))

(define-minor-mode mch/consult-completion-in-region
  "Minor mode enabling consult as completion in region function."
  :init-value nil
  :global nil
  (if mch/consult-completion-in-region
      (setq-local completion-in-region-function #'consult-completion-in-region)
    (kill-local-variable completion-in-region-function)))

;;;; Use completion-preview-mode in REPLs
(use-package comint
  :ensure nil
  :hook (comint-mode . mch/consult-completion-in-region)
  :config
  (setq ansi-color-for-comint-mode t
        comint-prompt-read-only t
        comint-buffer-maximum-size 4096))

(use-package compile
  :ensure nil
  :config
  (setq compilation-ask-about-save nil
        compilation-always-kill t
        compilation-max-output-line-length 2048
        compilation-scroll-output 'first-error))

;;;; Code folding
(use-package outline
  :ensure nil
  :hook (prog-mode . outline-minor-mode))

(use-package hideshow
  :ensure nil
  :hook (prog-mode . outline-minor-mode))

(use-package bicycle
  :ensure t
  :after outline
  :bind (:map outline-minor-mode-map
              ("C-<tab>" . bicycle-cycle)
              ("<backtab>" . bicycle-cycle-global)))

;;;; Lisps
;;;;; Structural editing
(use-package paredit
  :ensure t
  :hook ((lisp-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (scheme-mode . paredit-mode)
         (fennel-mode . paredit-mode))
  :config
  (keymap-unset paredit-mode-map "RET")
  (keymap-unset paredit-mode-map "M-s")
  (keymap-set paredit-mode-map "M-D" #'paredit-splice-sexp)
  (keymap-unset paredit-mode-map "M-?"))

;;;;; Better `electric-indent-mode' when editing structurally
(use-package aggressive-indent
  :ensure t
  :hook ((lisp-mode . aggressive-indent-mode)
         (emacs-lisp-mode . aggressive-indent-mode)
         (scheme-mode . aggressive-indent-mode)
         (fennel-mode . aggressive-indent-mode)))

;;;;; Emacs Lisp
(use-package ielm
  :ensure nil
  :hook (ielm-mode . electric-pair-local-mode))

;;;;; Scheme
(use-package geiser
  :ensure t
  :hook (scheme-mode . geiser-mode)
  :init
  (with-eval-after-load 'org
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((scheme . t)))))

(use-package geiser-racket
  :after geiser
  :ensure t)

;;;;; Fennel
(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fennel-mode)
  :config
  (with-eval-after-load 'org
    (require 'ob-fennel)))


;;; Writing
;;;; Visual line mode
(use-package text-mode
  :ensure nil
  :no-require t
  :hook (text-mode . visual-line-mode))

;;;; Org-mode
(use-package org
  :ensure nil
  :commands (org-mode org-version)
  :mode ("\\.org\\'" . org-mode)
  :bind (("C-c l" . #'org-store-link)
         ("C-c a" . #'org-agenda)
         ("C-c c" . #'org-capture))
  :hook (org-mode . (lambda () (electric-indent-local-mode -1)))
  :config
  (setq org-directory (expand-file-name "~/Org"))
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  (setq org-hide-leading-stars t))

(use-package typst-ts-mode
  :ensure t
  :mode ("\\.typ\\'" . typst-ts-mode)
  :interpreter "typst"
  :init
  (add-to-list 'major-mode-remap-alist '(typst-mode . typst-ts-mode)))

(use-package ox-typst
  :ensure t
  :after org
  :init
  (require 'ox-typst))

(use-package markdown-mode
  :ensure t
  ;; GitHub flavoured markdown for README.md files
  :mode ("README\\.md\\'" . gfm-mode))

;;; init.el ends here
