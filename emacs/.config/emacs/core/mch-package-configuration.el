;;; mch-package-configuration.el -*- lexical-binding: t; -*-

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

(use-package diminish
  :ensure t
  :demand t)

(provide 'mch-package-configuration)
