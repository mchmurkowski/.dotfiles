;; -*- lexical-binding: t -*-

(setopt gc-cons-threshold most-positive-fixnum)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setopt gc-cons-threshold (* 50 1024 1024))))

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(menu-bar-mode -1)

(setopt inhibit-startup-screen t)

(setopt default-frame-alist '((undecorated . t)))

(setopt native-comp-speed 2)
