;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Sachin Raut"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "roboto mono" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
;;(setq doom-theme 'doom-solarized-light)
(setq doom-theme 'doom-nord-light)

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
;(map! :n ",h" #'evil-window-left)
;(map! :n ",b" #'evil-window-bottom-right)
;(map! :n ",l" #'evil-window-right)
;(map! :n ",t" #'evil-window-top-left)
;(map! :n ",," #'evil-window-next)
(map! :n ",w" #'save-buffer)
;(map! :n ",h" #'avy-goto-char-2)

(setq ivy-re-builders-alist
      '((t . ivy--regex-ignore-order)))

(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")

(setq avy-keys '(?h ?t ?n ?s ?u ?e ?o ?d ?i))
(setq avy-keys-alist
      `((avy-goto-char-2 . (?h ?t ?n ?s ?u ?e ?o ?d ?i))))
(setq avy-all-windows t)

(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCELLED(c@)")
 (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))

;(setq key-chord-two-keys-delay 1)
;(key-chord-define evil-insert-state-map "hh" 'evil-normal-state)
;(key-chord-mode 1)

;ap! :n ",h" #'evil-window-left)
;(map! :n ",b" #'evil-window-bottom-right)
;(map! :n ",l" #'evil-window-right)
;(map! :n ",t" #'evil-window-top-left)
;(map! :n ",," #'evil-window-next)
(map! :n ",w" #'save-buffer)
;(map! :n ",h" #'avy-goto-char-2)

;(setq ivy-re-builders-alist
 ;     '((t . ivy--regex-fuzzy)))

(load-file "~/.doom.d/agenda.el")

(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")

(map! :leader
  ;(:prefix-map ("f" . "file")
 ;:desc "Find file"                   "f"   #'find-file
 :desc "Find file"                   "."   #'counsel-fzf
      )

(setq avy-keys '(?h ?t ?n ?s ?u ?e ?o ?d ?i))
(setq avy-keys-alist
      `((avy-goto-char-2 . (?h ?t ?n ?s ?u ?e ?o ?d ?i))))
(setq avy-all-windows t)

(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCELLED(c@)")
 (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))

;(setq key-chord-two-keys-delay 1)
;(key-chord-define evil-insert-state-map "hh" 'evil-normal-state)
;(key-chord-mode 1)

