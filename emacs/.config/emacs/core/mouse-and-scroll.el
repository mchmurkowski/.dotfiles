;;; mouse-and-scroll.el -*- lexical-binding: t; -*-

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
  (setopt next-screen-context-lines 6))

(provide 'mouse-and-scroll)
