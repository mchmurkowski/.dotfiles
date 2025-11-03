;;; mch-theme-and-font.el -*- lexical-binding: t; -*-

;; load theme
(if (and (not (display-graphic-p)) (getenv "WSLENV"))
    (load-theme 'modus-vivendi nil nil)
  (load-theme 'modus-operandi-tinted nil nil))

;; set default font
(if (getenv "WSLENV")
    (set-frame-font "IBM Plex Mono 15" nil t)
  (set-frame-font "IBM Plex Mono 13" nil t))

;; make fringes bigger
(fringe-mode 8)

(provide 'mch-theme-and-font)
