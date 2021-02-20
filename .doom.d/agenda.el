(setq org-directory "~/org")

(map! :map evil-org-mode-map :m ",t" 'org-todo)

(map! :map evil-org-mode-map :m "SPC m f" 'org-tags-sparse-tree)

(defun sr/open-agenda2 (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (org-agenda nil "x")
    )
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
      '(("x" "Sachin's Agenda"
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
                  (org-agenda-prefix-format "  %-15:c  %/b")
                  (org-agenda-sorting-strategy
                   '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if (= 1 1)
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            ;;(org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-agenda-prefix-format "  %-15:c  %/b ")
                            (org-tags-match-list-sublevels nil)
                            ;;(org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            ))
                (agenda "" ((org-agenda-span 5)(org-agenda-start-day ".")))
                (tags-todo "-CANCELLED/!NEXT"
                ((org-agenda-overriding-header "Next Tasks")
                 (org-agenda-skip-function t)
                 (org-agenda-prefix-format " %-4e  %/b ")
                 ;;(org-agenda-prefix-format " %/b %-4e  ")
                 (org-tags-match-list-sublevels t)
 ;                (add-hook 'org-agenda-finalize-hook #'sr/colorize-tags)
                 (org-agenda-todo-ignore-scheduled t)
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
                ))
("r" "Sachin's Agenda new"
         (
          ;; refile
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
          ;; projects
                (tags "+PROJECT"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-prefix-format "  %-15:c  %/b")
                            (org-agenda-sorting-strategy
                             '(priority-down category-keep))))
        ;; 5-day agenda
                (agenda "" ((org-agenda-span 5)(org-agenda-start-day ".")))
        ;; Next tasks
                (tags-todo "*/NEXT"
                           ((org-agenda-overriding-header "Next Tasks")
                            ;(org-agenda-skip-function 'bh/skip-non-projects)
                 (org-agenda-prefix-format " %-4e  %/b ")
                 ;;(org-agenda-prefix-format " %/b %-4e  ")
                 (org-tags-match-list-sublevels t)
 ;                (add-hook 'org-agenda-finalize-hook #'sr/colorize-tags)
                 (org-agenda-todo-ignore-scheduled t)
                 ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                 ;;(org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                 (org-agenda-sorting-strategy
                  '(priority-down todo-state-down effort-up category-keep))))

                (tags-todo "*/TODO"
                           ((org-agenda-overriding-header "Someday Tasks")
                            ;;(org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-agenda-prefix-format "  %/b")
                            (org-tags-match-list-sublevels t)
                            ;;(org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            ;;(org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))
                ))))
        ))

(setq org-tags-exclude-from-inheritance '("PROJECT"))

(setq org-agenda-timegrid-use-ampm 1)

(setq org-time-stamp-rounding-minutes (quote (0 15)))

(customize-set-variable 'org-agenda-fontify-priorities t)

(setq org-agenda-prefix-format '((agenda . " %i %-15:c %-14t% s%-6e %/b ")
                                 (tags . " %i %-12:c")
                                 (todo . " %i %-12:c")
                                 (search . " %i %-12:c")))

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
(setq org-agenda-dim-blocked-tasks nil)

(setq org-agenda-block-separator ?⎼)
(setq org-agenda-block-separator ? )

; to execute
(setq org-refile-targets '(("home.org" :level . 1)))
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue")
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold))))
;(map! :map evil-org-agenda-mode-map :m "f" 'org-agenda-filter-by-top-headline))

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

;; my leader binding
(map! :leader
  ;;; <leader> e --- sachin
  (:prefix-map ("e" . "sachin")
    :desc "Open Agenda"                 "a"   #'sr/open-agenda
    :desc "Open old Agenda"             "n"   #'sr/open-agenda2
    :desc "switch buffer(other-window)" "b"   #'consult-buffer
    :desc "switch buffer other window"  ",b"  #'consult-buffer-other-window
    :desc "org headings"                "h"   #'counsel-org-goto-all
    :desc "M-x"                         "e"   #'counsel-M-x
    )
  ;;; search extension s
  :n "sx" #'evil-ex-nohighlight
  )

(defun sr/org-add-child()
    "Mark the current TODO as done and add another task after it.
Creates it at the same level as the previous task, so it's better to use
this with to-do items than with projects or headings."
    (interactive)
    (org-agenda-goto)
    (+org/insert-item-below 1)
    (org-demote-subtree))

(defun sr/org-mark-done-add-next ()
    "Mark the current TODO as done and add another task after it.
Creates it at the same level as the previous task, so it's better to use
this with to-do items than with projects or headings."
    (interactive)
    (org-agenda-todo "DONE")
    (org-agenda-goto)
    (+org/insert-item-below 1))

;; Do not show deadline in org agenda if it is completed already.
(setq org-agenda-skip-deadline-if-done t)

;; org agenda mode binding
(map! :map evil-org-agenda-mode-map
  :m "n" 'org-agenda-next-item
  :m "b" 'org-agenda-previous-item
  :m ",w" 'org-save-all-org-buffers
  :m "r" 'org-agenda-redo-all
  :m "t" 'org-agenda-todo
  :m "p" 'org-agenda-priority
  :m "h" 'org-agenda-date-earlier-minutes
  :m "l" 'org-agenda-date-later-minutes
  :m "H" 'org-agenda-date-earlier
  :m "L" 'org-agenda-date-later
  :m "cn" 'sr/org-mark-done-add-next
  :m "cc" 'sr/org-add-child
  :m "sh" 'org-agenda-filter-by-top-headline
  :m "/" 'counsel-grep-or-swiper
  :m "sx" 'evil-ex-nohighlight)

(defun +sachin/org-notes-headlines ()
  "Jump to an Org headline in `org-agenda-files'."
  (interactive)
  (doom-completing-read-org-headings
   "Jump to org headline: " org-agenda-files 10 t))

(setq counsel-search-engine 'google)
(use-package org
  :config
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
          )))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

(use-package embark
  :ensure t
  :bind
  ("C-9" . embark-act))
