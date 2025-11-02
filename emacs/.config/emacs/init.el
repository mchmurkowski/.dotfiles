;;; init.el -*- lexical-binding: t; -*-

(defvar mch-config-dir (file-name-directory load-file-name))
(defvar mch-config-core-dir (expand-file-name "core" mch-config-dir))
(defvar mch-config-modules-dir (expand-file-name "modules" mch-config-dir))

(add-to-list 'load-path mch-config-core-dir)
(add-to-list 'load-path mch-config-modules-dir)

;;; Core

(require 'mch-package-configuration) ; sources and use-package
(require 'mch-trash-and-history) ; customfile, backups, lockfiles, autosaves & recentfiles
(require 'mch-theme-and-font) ; set theme and font
(require 'mch-basic-settings) ; basic, sane settings
(require 'mch-better-minibuffer) ; vertico, marginalia, consult, orderless, which-key
(require 'mch-navigation-and-scrolling) ; mouse navigation & scrolling behaviour
(require 'mch-modal-editing) ; modal editing with meow

;;; Modules
(require 'mch-modeline)
(require 'mch-coding)

(provide 'mch-init)
