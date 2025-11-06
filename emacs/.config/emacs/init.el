;;; init.el -*- lexical-binding: t; -*-


;;; Setting up package repositories and `use-package`
(require 'package)
(setopt package-archives
    '(("gnu" . "https://elpa.gnu.org/packages/")
      ("melpa" . "https://melpa.org/packages/")))
(unless (bound-and-true-p package--initialized) (package-initialize))
(unless package-archive-contents (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
;; (setopt use-package-always-ensure t)
(setopt use-package-always-defer t)

;; Install `diminish` to hide minor modes from modeline
(use-package diminish
  :ensure t
  :demand t)


;;; Deal with unwanted files
;; deal with custom-file
(setopt custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-missing)

;; do not make backups & lockfiles
(setopt make-backup-files nil)
(setopt create-lockfiles nil)

;; put autosaves in one place & stop notyfing me on autosave
(defvar mch-tmp-dir (expand-file-name "tmp/" user-emacs-directory))
(defvar mch-autosave-dir (expand-file-name "autosaves/" mch-tmp-dir))
(dolist (d (list mch-tmp-dir mch-autosave-dir))
  (unless (file-directory-p d) (make-directory d t)))
(setopt auto-save-file-name-transforms `((".*" ,mch-autosave-dir t)))
(setopt auto-save-no-message t)

;; store information on recently visted files
(use-package recentf
  :ensure nil
  :bind
  ("C-x C-r". recentf-open)
  :config
  (setopt recentf-max-saved-items 75)
  (setopt recentf-max-menu-items 15)
  (setopt recentf-auto-cleanup 'never))


;;; Looks - themes, fonts, ui
;; set the theme
(if (and (not (display-graphic-p)) (getenv "WSLENV"))
    (load-theme 'modus-vivendi nil nil)
  (load-theme 'modus-operandi-tinted nil nil))

;; set the default font
(if (getenv "WSLENV")
    (set-frame-font "IBM Plex Mono 15" nil t)
  (set-frame-font "IBM Plex Mono 13" nil t))

;; make fringes bigger
(fringe-mode '(16 . 8))

;; modeline
(use-package mood-line
  :ensure t
  :init
  (mood-line-mode))


;;; Basic, sane settings
;; disable ringing & flashing
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

;; follow symlinks
(setopt find-file-visit-truename t)
(setopt vc-follow-symlinks t)
(setopt find-file-suppress-same-file-warnings t)

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


;;; Better minibuffer - `vertico`, `consult`, `which-key` and like
(use-package emacs
  :ensure nil
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode 1))

(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
     ("C-x b" . consult-buffer)
     ("C-x C-f" . find-file)
     ("M-y" . consult-yank-pop)))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :init (which-key-mode)
  :config
  (setopt which-key-idle-delay 0.5))


;;; Mouse navigation & scrolling behaviour
(use-package mouse
  :ensure nil
  :hook (after-init . mouse-wheel-mode)
  :config
  ;; focus follows mouse
  (setopt mouse-autoselect-window t)
  (setopt focus-follows-mouse t)
  (setopt mouse-wheel-scroll-amount
      '(1
        ((shift) . 5)
        ((meta) . 0.5)
        ((control) . text-scale)))
  (setopt mouse-drag-copy-region nil)
  (setopt make-pointer-invisible t)
  (setopt mouse-wheel-progressive-speed t)
  (setopt mouse-wheel-follow-mouse t)
  (setopt scroll-preserve-screen-position t)
  (setopt scroll-conservatively 1)
  (setopt scroll-margin 6)
  (setopt hscroll-margin 8)
  (setopt next-screen-context-lines 6)
  (unless (display-graphic-p)
    (xterm-mouse-mode 1)))


;;; Modal editing - `meow`
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
      '("/" . consult-line)))
  :config
  (meow-setup)
  (meow-global-mode))


;; Coding
;; enable line numbers in prog and conf modes
(defun mch-work-with-code ()
  "Enable settings that help working with code"
  ;; relative line numbers
  (setopt display-line-numbers-width 3)
  (setopt display-line-numbers-type 'relative)
  (display-line-numbers-mode 1)
  ;; use spaces not tabs
  (setopt indent-tabs-mode nil)
  (setopt tab-width 4)
  ;; display fill column
  (setopt fill-column 80)
  (display-fill-column-indicator-mode t)
  ;; word-wrapping
  (setopt word-wrap t)
  (setopt truncate-lines t)
  (setopt truncate-partial-width-windows nil))

(add-hook 'prog-mode-hook #'mch-work-with-code)
(add-hook 'conf-mode-hook #'mch-work-with-code)
;; use visual line mode in text-mode
(add-hook 'text-mode-hook #'visual-line-mode)

;; editorconfig
(use-package editorconfig
  :ensure nil
  :diminish editorconfig-mode
  :init
  (editorconfig-mode 1))

;; code completion
(use-package emacs
  :ensure nil
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-separator ?\s)
  (corfu-quit-at-boundry nil)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  (corfu-scroll-margin 5)
  (completion-styles '(orderless basic))
  :init
  (global-corfu-mode)
  (corfu-history-mode t)
  (corfu-indexed-mode t)
  (corfu-popupinfo-mode t)
  (setopt corfu-auto-delay 0.0)
  (setopt corfu-auto-prefix 2)
  (setopt corfu-quit-no-match 'separator)
  :bind (:map corfu-map
          ("C-n" . corfu-next)
          ("C-p" . corfu-previous)
          ("<escape>" . corfu-quit)
          ("<return>" . corfu-insert)
          ("M-d" . corfu-show-documentation)
          ("M-l" . corfu-show-location)))

(use-package cape
  :ensure t
  :defer t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

;; lsp setup
(use-package eglot
  :ensure nil
  :defer t
  :hook ((python-mode . eglot-ensure)
     (python-ts-mode . eglot-ensure)
     (lua-ts-mode . eglot-ensure)
     (fennel-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
           `(python-ts-mode
         . ,(eglot-alternatives `(("basedpyright-langserver" "--stdio")
                      ("ruff" "server")))))
  (add-to-list 'eglot-server-programs
           `(lua-ts-mode . ("lua-language-server")))
  (add-to-list 'eglot-server-programs
           `(fennel-mode . ("fennel-ls")))
  :custom
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :documentFormattingProvider
     :documentRangeFormattingProvider
     :documentOnTypeFormattingProvider
     :colorProvider
     :foldingRangeProvider
     :inlayHintProvider)))

;; language-specific-settings
(use-package python
  :ensure nil
  :mode (("\\.py\\'" . python-ts-mode)))

(use-package lua-ts-mode
  :ensure nil
  :mode (("\\.lua\\'" . lua-ts-mode)))

(use-package fennel-mode
  :ensure t
  :mode (("\\.fnl\\'" . fennel-mode))
  :config
  (with-eval-after-load 'org
    (require 'ob-fennel)))

(provide 'mch-init)
