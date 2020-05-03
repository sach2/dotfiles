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
(setq doom-theme 'doom-solarized-light)

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
;(map! :n ",h" #'evil-window-left)
;(map! :n ",b" #'evil-window-bottom-right)
;(map! :n ",l" #'evil-window-right)
;(map! :n ",t" #'evil-window-top-left)
;(map! :n ",," #'evil-window-next)
;(map! :n ",s" #'save-buffer)
;(map! :n ",h" #'avy-goto-char-2)

(setq ivy-re-builders-alist
      '((t . ivy--regex-fuzzy)))

(map! :map evil-org-agenda-mode-map :m "f" 'org-agenda-filter)
(map! :map evil-org-agenda-mode-map :m "t" 'org-agenda-todo)
(map! :map evil-org-agenda-mode-map :m "p" 'org-agenda-priority)

(map! :map evil-org-agenda-mode-map :m "h" 'org-agenda-date-earlier-minutes)
(map! :map evil-org-agenda-mode-map :m "l" 'org-agenda-date-later-minutes)

(map! :map evil-org-agenda-mode-map :m "H" 'org-agenda-date-earlier)
(map! :map evil-org-agenda-mode-map :m "L" 'org-agenda-date-later)

(map! :map evil-org-agenda-mode-map :m "s" 'org-save-all-org-buffers)
(map! :map evil-org-agenda-mode-map :m "r" 'org-agenda-redo-all)

(map! :map evil-org-agenda-mode-map :m "n" 'org-agenda-next-item)
(map! :map evil-org-agenda-mode-map :m "b" 'org-agenda-previous-item)

(map! :map evil-org-agenda-mode-map :m "M-s" 'org-agenda-schedule)

(map! :map evil-org-mode-map :m ",t" 'org-todo)

(map! :map evil-org-mode-map :m "SPC m f" 'org-tags-sparse-tree)

(map! :map evil-org-mode-map :m "M-m" 'org-tags-sparse-tree)

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
         (
          (agenda "" ((org-agenda-ndays 1)))
          (todo "NEXT"
                ((org-agenda-sorting-strategy '(tag-up))
                 (org-agenda-prefix-format " %i %-14t% s%?/T ")
                 (org-agenda-overriding-header "Next items:")
                 ))
          ;((org-agenda-compact-blocks t))
          ))))

(defun air-pop-to-org-agenda (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (org-agenda nil "d")
;;  (when (not split)
 ;;   (delete-other-windows)
    )

(define-key evil-normal-state-map (kbd "--") 'air-pop-to-org-agenda)
;(define-key evil-insert-state-map (kbd "-") 'evil-normal-state)
;(define-key evil-insert-state-map (kbd "ht") 'evil-normal-state)

(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")


(setq avy-keys '(?h ?t ?n ?s ?u ?e ?o ?d ?i))
(setq avy-keys-alist
      `((avy-goto-char-2 . (?h ?t ?n ?s ?u ?e ?o ?d ?i))))
(setq avy-all-windows t)

(setq org-agenda-timegrid-use-ampm 1)

(setq org-time-stamp-rounding-minutes (quote (0 15)))

(customize-set-variable 'org-agenda-fontify-priorities t)
(customize-set-variable 'org-priority-faces
                        (quote ((?A :foreground "magenta3")
                                (?B :foreground "SpringGreen4")
                                (?C :foreground "darkorange3"))))
(customize-set-variable 'org-default-priority ?C)

(setq org-agenda-prefix-format '((agenda . " %i %-14t% s%?/T ")
                                 (tags . " %i %-12:c")
                                 (todo . " %i %-12:c")
                                 (search . " %i %-12:c")))

(defun sr/colorize-tags-with (col)
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
      (let (
            (tag-end (or (search-forward "/")
                         (point-at-bol))))
        (if (not(eq tag-end (point-at-bol)))
            (let (
                  (tag-start (or (search-backward " ")
                                 (point-at-eol))))
              ;(delete-region (- tag-end 1) tag-end)
              (add-text-properties (+ tag-start 1)
                                   ;(+ tag-start 20)
                                   tag-end
                                   `(face (:foreground , col)))
              )
          () ))
      (forward-line 1)
      ))

(defun sr/colorize-tags ()
  (sr/colorize-tags-with "gray10"))
; brown4
; gray10

(add-hook 'org-agenda-finalize-hook #'sr/colorize-tags)

(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "SCHEDULED(s)" "WAIT(w@/!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCEL(c@)")
 (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))
