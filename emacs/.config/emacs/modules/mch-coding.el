;;; mch-coding.el -*- lexical-binding: t; -*-

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

(provide 'mch-coding)
