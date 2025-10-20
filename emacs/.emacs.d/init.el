;; -*- lexical-binding: t -*-


;; deal with custom file
(setopt custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)


;; add modules to path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))


;; set theme and fonts
(if (display-graphic-p)
    (progn
      (load-theme 'modus-operandi-tinted t)
      (set-frame-font "IBM Plex Mono 13" nil t)
      (set-fringe-mode 10))
  ;; use dark theme on WSL
  (when (string= (system-name) "LAPTOP-O7M8TTB2")
    (progn
      (load-theme 'modus-vivendi t))))


;; setup use-package
(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(when (< emacs-major-version 29)
  (unless (package-installed-p 'use-package)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'use-package)))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))


;; basic settings and improvements
(use-package emacs
  :ensure nil
  :init
  (setopt initial-major-mode 'fundamental-mode)
  (setopt initial-scratch-message "")
  :config
  (setopt create-lockfiles nil)
  (setopt make-backup-files nil)
  (setopt auto-save-no-message t)
  (setopt use-short-answers t)
  (setopt visible-bell nil)
  (setopt ring-bell-function #'ignore)
  (setopt find-file-visit-truename t)
  (setopt vc-follow-symlinks t)
  (setopt sentence-end-double-space nil)
  (setopt require-final-newline t)
  (setopt indent-tabs-mode nil)
  (setopt tab-width 4))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package recentf
  :ensure nil
  :config
  (setopt recentf-max-saved-items 50)
  (setopt recentf-max-menu-items 10)
  (global-set-key (kbd "C-x C-r") 'recentf-open-files)
  :hook (after-init . recentf-mode))


;; help
(use-package which-key
  :ensure nil
  :config
  (setopt which-key-max-display-columns 3)
  (setopt whick-key-idle-delay 1.5)
  :hook (after-init . which-key-mode))

(use-package helpful
  :ensure t
  :bind (("C-h f" . #'helpful-callable)
         ("C-h v" . #'helpful-variable)
         ("C-h k" . #'helpful-key)
         ("C-h C-d". #'helpful-at-point)
         ("C-h F" . #'helpful-function)
         ("C-h C" . #'helpful-command)))


;; run emacs as a server
(use-package server
  :ensure nil
  :defer 1
  :config
  (setq server-client-instructions nil)
  (unless (or (server-running-p) (daemonp))
    (server-start)))


;; editing
(use-package display-line-numbers
  :ensure nil
  :config
  (setopt display-line-numbers-width 4)
  (setopt display-line-numbers-type 'relative)
  :hook
  ((prog-mode . display-line-numbers-mode)
   (conf-mode . display-line-numbers-mode)))

;;; modal editing via meow
(require 'meow-module)

(use-package editorconfig
  :ensure nil
  :hook
  ((prog-mode . editorconfig-mode)
   (conf-mode . editorconfig-mode)))


;; minibuffer improvements: vertico, marginalia, consult etc.
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setopt completion-styles '(orderless basic))
  (setopt completion-category-defaults nil)
  (setopt completion-category-overrides nil))

(use-package consult
  :ensure t
  :init
  (global-unset-key (kbd "C-z")) ;; disable C-z (suspend-frame) and use as consult prefix
  :bind (
         ("C-z g" . consult-grep)
         ("C-z f" . consult-find)
         ("C-z o" . consult-outline)
         ("C-z l" . consult-line)
         ("C-z b" . consult-buffer)))


;; completion
(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :init
  (setopt tab-always-indent 'complete)
  :config
  (setopt corfu-preview-current nil)
  (setopt corfu-min-width 20)
  (setopt corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1)
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))
