(setq org-directory "~/org")

(add-hook 'org-agenda-mode-hook
          (lambda ()
	    ;; Navigate agenda
	    (define-key org-agenda-mode-map (kbd "f") 'org-agenda-filter)
	    (define-key org-agenda-mode-map (kbd "k") 'org-agenda-previous-item)
	    (define-key org-agenda-mode-map (kbd "M-k") 'windmove-up)))

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

(defun sr/open-agenda (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (org-agenda nil "r")
    )
(defun sr/open-rofi ()
  (interactive)
  (set-variable 'shell-command-switch "-ic")
  (with-output-to-temp-buffer "bluetooth" (setq ot (shell-command-to-string "bluetoothctl devices")) (print ot)
  ;;(setq ot "test")
  )
  (switch-to-buffer-other-window "bluetooth")
)
(defun sr/open-rofi2 ()
  (interactive)
  (set-variable 'shell-command-switch "-ic")
  (get-buffer-create "*outt*")
  (shell-command "bluetoothctl devices")
  ;;(setq ot "test")
  (switch-to-buffer-other-window "*outt*")
)
(define-key evil-normal-state-map (kbd "SPC 8") 'sr/open-agenda)
(define-key evil-normal-state-map (kbd "SPC e a") 'sr/open-agenda)
(define-key evil-normal-state-map (kbd "SPC e r") 'sr/open-rofi)
(define-key evil-normal-state-map (kbd "SPC e b") 'counsel-switch-buffer)
(define-key evil-normal-state-map (kbd "SPC e , b") 'counsel-switch-buffer-other-window)
(define-key evil-normal-state-map (kbd "SPC e e") 'counsel-M-x)
(define-key evil-normal-state-map (kbd "<delete> e m") 'counsel-ibuffer)
; to execute after startup
(map! :map evil-org-mode-map :m "M-s" 'org-tags-sparse-tree)

(map! :map evil-org-mode-map :m "M-n" 'org-narrow-to-subtree)

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

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))
;;
(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))
(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(setq org-agenda-custom-commands
      '(("d" "Daily agenda and all TODOs"
         ((agenda "" ((org-agenda-span 1)(org-agenda-start-day "-1d"))
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil))))
          (todo "NEXT"
                ((org-agenda-sorting-strategy '(tag-up))
                 (org-agenda-prefix-format " %i %-14t% s%?/T %/b ")
                 (org-agenda-overriding-header "Next items:")
                 ))
         ((org-agenda-remove-tags t))))
        ("r" "Daily agenda and all TODOs - 2"
         (
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-agenda-prefix-format "  %-30:c  %/b")
                            (org-agenda-sorting-strategy
                             '(priority-down category-keep))))
                (tags-todo "-CANCELLED/!"
                 ((org-agenda-overriding-header "Stuck Projects")
                  (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                  (org-agenda-prefix-format "  %-30:c  %/b")
                  (org-agenda-sorting-strategy
                   '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if (= 1 1)
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            ;;(org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-agenda-prefix-format "  %-30:c  %/b ")
                            (org-tags-match-list-sublevels nil)
                            ;;(org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            ))
                (agenda "" ((org-agenda-span 5)(org-agenda-start-day ".")))
                (tags-todo "-CANCELLED/!NEXT"
                ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                       (if (= 1 1)
                                                           ""
                                                         " (including WAITING and SCHEDULED tasks)")))
                 (org-agenda-skip-function t)
                 ;;(org-agenda-prefix-format " %-4e  %/b ")
                 (org-agenda-prefix-format " %-4e  ")
                 (org-tags-match-list-sublevels t)
 ;                (add-hook 'org-agenda-finalize-hook #'sr/colorize-tags)
                 ;;(org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                 ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                 ;;(org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                 (org-agenda-sorting-strategy
                  '(priority-down todo-state-down effort-up category-keep))))
                (tags-todo "*/TODO"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if (= 1 1)
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            ;;(org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-agenda-prefix-format "  %/b")
                            (org-tags-match-list-sublevels t)
                            ;;(org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                ))))


(setq org-agenda-timegrid-use-ampm 1)

(setq org-time-stamp-rounding-minutes (quote (0 15)))

(customize-set-variable 'org-agenda-fontify-priorities t)

(setq org-agenda-prefix-format '((agenda . " %i %-30:c %-14t% s%-6e %/b ")
                                 (tags . " %i %-12:c")
                                 (todo . " %i %-12:c")
                                 (search . " %i %-12:c")))

(defun sr/colorize-tags-with (col)
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
      (let (
            (tag-end (or (search-forward "->")
                         (point-at-bol))))
        (if (not(eq tag-end (point-at-bol)))
            (let (
                  (tag-start (or (search-backward "  ")
                                 (point-at-eol))))
              ;;(delete-region tag-end (- tag-end 2))
              (add-text-properties (+ tag-start 1)
                                   tag-end
                                   ;`(face 'bold))
                                   `(face (:foreground , col)))
              )
          () ))
      (forward-line 1)
      ))

(defun sr/colorize-tags ()
 ;  (sr/colorize-tags-with "brown4"))
; brown4
; gray10
 )

(add-hook 'org-agenda-finalize-hook #'sr/colorize-tags)

(setq shell-command-switch "-ic")
(setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCELLED(c@)")
 (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))
(setq org-log-into-drawer t)

(setq org-enforce-todo-dependencies t)
(setq org-track-ordered-property-with-tag t)
(setq org-agenda-dim-blocked-tasks t)
; to execute
(after! org
(setq org-capture-templates
      '(("s" "Scheduled Task" entry
         (file "refile.org" )
         "* %?\nSCHEDULED: %^t\n")
        ("t" "Tasks")
        ("tn" "Next Task" entry
         (file "refile.org" )
         "* NEXT %?\n :PROPERTIES:\n:Effort: %^{Effort}\n:END:")
        ("tt" "Todo Task" entry
         (file "refile.org" )
         "* TODO %?\n :PROPERTIES:\n:Effort: %^{Effort}\n:END:")
        ("d" "Deadline" entry
         (file "refile.org" )
         "* %?\nDEADLINE: %^t\n")
        ("n" "Note" entry
         (file "refile.org" )
         "* %?\n")
        ("p" "Project" entry
         (file "sachin.org" )
         "* TODO %?\n")
        ("j" "Journal" entry (file+datetree "journal.org")
         "* %?\nEntered on %U\n  %i")
        ))
(setq org-refile-targets '(("sachin.org" :level . 1)))
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue")
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold))))
(map! :map evil-org-agenda-mode-map :m "f" 'org-agenda-filter-by-top-headline))

(global-set-key (kbd "M-c") 'org-capture)
 (defun my/org-agenda-mark-done-and-add-followup ()
    "Mark the current TODO as done and add another task after it.
Creates it at the same level as the previous task, so it's better to use
this with to-do items than with projects or headings."
    (interactive)
    (org-agenda-todo "DONE")
    (org-agenda-goto)
    (org-capture 0 "tn"))
    ;;(+org/insert-item-below 1))
;; Override the key definition
;(define-key org-agenda-mode-map "X" 'my/org-agenda-mark-done-and-add-followup)

;(define-key org-capture-mode-map (kbd "M-s") 'org-capture-finalize)
;(define-key org-capture-mode-map (kbd "M-r") '+org/refile-to-file)
;(define-key org-capture-mode-map (kbd "M-c") 'org-capture-kill)

(setq shell-file-name "/bin/zsh")
(customize-set-variable 'tramp-encoding-shell "/bin/zsh")
