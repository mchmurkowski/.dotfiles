;;; mch-better-minibuffer.el -*- lexical-binding: t; -*-

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
  :config (setopt which-key-idle-delay 0.5))

(provide 'mch-better-minibuffer)
