;; -*- lexical-binding: t -*-

(setopt gc-cons-threshold most-positive-fixnum)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setopt gc-cons-threshold (* 50 1024 1024))))

(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)))

(menu-bar-mode -1)

(setopt inhibit-startup-screen t)

(load-theme 'modus-vivendi t)

(setopt native-comp-speed 2)
