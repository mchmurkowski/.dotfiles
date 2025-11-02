;;; mch-theme-and-font.el -*- lexical-binding: t; -*-

;; load theme
(load-theme 'modus-operandi-tinted nil nil)

;; set default font
(set-frame-font "IBM Plex Mono 13" nil t)

;; make fringes bigger
(fringe-mode 8)

(provide 'mch-theme-and-font)
