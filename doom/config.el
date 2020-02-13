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
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-nord)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "/mnt/e/Dropbox/org/")


;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type 'relative)


(add-hook 'org-agenda-mode-hook
          (lambda ()
	    ;; Navigate agenda
	    (define-key org-agenda-mode-map (kbd "f") 'org-agenda-filter)
	    (define-key org-agenda-mode-map (kbd "k") 'org-agenda-previous-item)
	    (define-key org-agenda-mode-map (kbd "M-k") 'windmove-up)))
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
(map! :n ",h" #'evil-window-left)
(map! :n ",b" #'evil-window-bottom-right)
(map! :n ",l" #'evil-window-right)
(map! :n ",t" #'evil-window-top-left)
(map! :n ",," #'evil-window-next)
(map! :n ",s" #'save-buffer)
(map! :n ",h" #'avy-goto-char-2)

(setq ivy-re-builders-alist
      '((t . ivy--regex-fuzzy)))

(map! :map evil-org-agenda-mode-map :m "f" 'org-agenda-filter)
(map! :map evil-org-agenda-mode-map :m "t" 'org-agenda-todo)
(map! :map evil-org-agenda-mode-map :m "p" 'org-agenda-priority)
(map! :map evil-org-agenda-mode-map :m "_" 'org-agenda-priority-up)
(map! :map evil-org-agenda-mode-map :m "+" 'org-agenda-priority-up)
(map! :map evil-org-agenda-mode-map :m "-" 'org-agenda-priority-down)

(map! :map evil-org-agenda-mode-map :m "h" 'org-agenda-date-earlier)
(map! :map evil-org-agenda-mode-map :m "l" 'org-agenda-date-later)

(map! :map evil-org-agenda-mode-map :m "s" 'org-save-all-org-buffers)
(map! :map evil-org-agenda-mode-map :m "r" 'org-agenda-redo-all)

(map! :map evil-org-agenda-mode-map :m "j" 'org-agenda-next-item)
(map! :map evil-org-agenda-mode-map :m "k" 'org-agenda-previous-item)

(defun air-org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))
(defun air-org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.
PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(setq org-agenda-custom-commands
      '(("d" "Daily agenda and all TODOs"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (agenda "" ((org-agenda-ndays 1)))
          (alltodo ""
                   ((org-agenda-skip-function '(or (air-org-skip-subtree-if-habit)
                                                   (air-org-skip-subtree-if-priority ?A)
                                                   (org-agenda-skip-if nil '(scheduled deadline))))
                    (org-agenda-overriding-header "ALL normal priority tasks:"))))
         ((org-agenda-compact-blocks t)))))
(defun air-pop-to-org-agenda (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (org-agenda nil "d")
;;  (when (not split)
 ;;   (delete-other-windows)
    )

(define-key evil-normal-state-map (kbd ",o") 'air-pop-to-org-agenda)


(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")


(setq avy-keys '(?h ?t ?n ?s ?u ?e ?o ?d ?i))
(setq avy-keys-alist
      `((avy-goto-char-2 . (?h ?t ?n ?s ?u ?e ?o ?d ?i))))
(setq avy-all-windows t)
