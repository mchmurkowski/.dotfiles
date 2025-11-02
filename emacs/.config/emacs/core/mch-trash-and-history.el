;;; mch-trash-and-history.el -*- lexical-binding: t; -*-

;; deal with custom-file
(setopt custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-missing)

;; do not litter
(setopt make-backup-files nil)
(setopt create-lockfiles nil)

;; put autosaves in one place & stop notyfing me on autosaves
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
 
(provide 'mch-trash-and-history)
