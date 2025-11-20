;;; early-init.el -*- lexical-binding: t -*-

;; Maximize GC threshold during startup to prevent collections
(setopt gc-cons-threshold most-positive-fixnum)
(setopt gc-cons-percentage 0.5)

;; Store default file-name-handler-alist and restore after startup
(defvar default-file-name-handler-alist file-name-handler-alist)
(setopt file-name-handler-alist nil)

;; Disable automatic file handler during startup
(setopt auto-mode-case-fold nil)

;; Disable package.el at startup (handled in init.el)
(setopt package-enable-at-startup nil)
(setopt package-quickstart nil)

;; Prevent premature loading of packages
(setopt load-prefer-newer t)

;; Disable UI elements before they're rendered (faster startup)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Early GUI toggles must be guarded for batch/tty
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Alternative method for Emacs 27+
;; (setopt default-frame-alist
;;         (append (list
;;                  '(min-height 1)
;;                  '(height . 45)
;;                  '(width . 81)
;;                  '(fullscreen . maximized))))

(when (not (getenv "WSLENV"))
  (push '(undecorated . t) default-frame-alist))

;; Disable startup screens
(setopt inhibit-startup-screen t)
(setopt inhibit-startup-message t)
(setopt inhibit-startup-echo-area-message user-login-name)
(setopt inhibit-default-init t)
(setopt initial-scratch-message nil)

;; Hairline dividers, theme-colored, no extra padding
(setopt window-divider-default-right-width 2)
(setopt window-divider-default-bottom-width 2)
(setopt window-divider-default-places t)
(window-divider-mode 1)

;; No frame padding for maximum content area
(modify-all-frames-parameters '((internal-border-width . 0)))

;; Set fringes up
(when (fboundp 'fringe-mode) (fringe-mode '(16 . 8)))

;; Prevent frame resizing when adjusting fonts
(setopt frame-resize-pixelwise t)
(setopt frame-inhibit-implied-resize t)

;; Set frame title
(setopt frame-title-format '("%b - Emacs"))
(setopt icon-title-format frame-title-format)

;; Disable version control during startup
(defvar default-vc-handled-backends vc-handled-backends)
(setopt vc-handled-backends nil)

;; Disable site-run-file
(setq site-run-file nil)

;; Disable biderectional text rendering for slight performance boost
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; Native compilation settings (Emacs 28+)
(when (featurep 'native-compile)
  (setopt native-comp-speed 2)
  (setopt native-comp-async-report-warnings-errors nil)
  (setopt native-comp-deferred-compilation t)
  (setopt native-comp-async-jobs-number 4))

;; Increase the amount of data read from processes
(setopt read-process-output-max (* 1024 1024)) ; 1MB

;; Reduce pgtk timeout for better performance on Wayland
(when (featurep 'pgtk)
  (setopt pgtk-wait-for-event-timeout 0.001))

;; Disable warnings and reduce noise
(setq byte-compile-warnings '(not obsolete)
      warning-supress-log-types '((comp) (bytecomp))
      native-comp-async-report-warnings-errors 'silent)

;; Faster font rendering
(setopt inhibit-compacting-font-caches t)

;; Restore options on startup
(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Restore GC settings (16MB threshold)
            (setopt gc-cons-threshold (* 16 1024 1024))
            (setopt gc-cons-percentage 0.1)
            ;; Restore file name handler
            (setopt file-name-handler-alist default-file-name-handler-alist)
            ;; Restore version control backend
            (setopt vc-handled-backends default-vc-handled-backends)
            ;; Collect garbage when losing focus
            (add-function :after after-focus-change-function
                          (lambda ()
                            (unless (frame-focus-state)
                              (garbage-collect))))
            ;; Display startup time
            (message "Emacs loaded in %s with %d garbage collections."
                     (emacs-init-time "%.2f seconds")
                     gcs-done)))
