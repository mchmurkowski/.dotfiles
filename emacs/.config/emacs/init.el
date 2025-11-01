;;; init.el -*- lexical-binding: t; -*-

(defvar mch-config-dir (file-name-directory load-file-name))
(defvar mch-config-core-dir (expand-file-name "core" mch-config-dir))
(defvar mch-config-modules-dir (expand-file-name "modules" mch-config-dir))

(add-to-list 'load-path mch-config-core-dir)
(add-to-list 'load-path mch-config-modules-dir)

;;; Core

(require 'packages-configuration) ; sources and use-package
(require 'trash-and-history) ; customfile, backups, lockfiles, autosaves & recentfiles
(require 'theme-and-font) ; set theme and font
(require 'sane-settings) ; basic, sane settings
(require 'better-minibuffer) ; vertico, marginalia, consult, orderless, which-key
(require 'mouse-and-scroll) ; mouse navigation & scrolling behaviour
(require 'modal-editing) ; modal editing with meow

(provide 'mch-init)
