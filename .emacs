(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(cperl-tab-always-indent t)
 '(cua-mode t nil (cua-base))
 '(org-agenda-files (quote ("~/working/org/sabre.org")))
 '(scalable-fonts-allowed t)
 '(show-paren-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#111" :foreground "#ddd" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 103 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(mode-line ((t (:background "DarkRed" :foreground "#ddd" :box (:line-width -1 :style released-button))))))

;; Cperl
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist (cons '("\\.t$|\\.cgi$" . cperl-mode) auto-mode-alist))

;; Use 4 space indents via cperl mode


;; Insert spaces instead of tabs
(setq-default indent-tabs-mode nil)


;; From: http://www.perlmonks.org/index.pl?node_id=380724
;; 
;; Put this in your ~/.emacs file, select the region you
;; want to clean up and type C-xt or M-x perltidy-region.

(global-set-key "\C-xt" 'perltidy-region)
(defun perltidy-region ()
  "Run perltidy on the current region or the whole buffer."
  (interactive)
  (save-excursion
    (let ((beg (if mark-active (point) (point-min)))
          (end (if mark-active (mark) (point-max)))) 
      (shell-command-on-region beg end "perltidy -q" nil t))))


(global-set-key [(control /)] 'comment-or-uncomment-region)

;; Load uploader
(load  "~/.emacs.d/mimic.el")

(defun rename-current-file-or-buffer ()
  (interactive)
  (if (not (buffer-file-name))
      (call-interactively 'rename-buffer)
    (let ((file (buffer-file-name)))
      (with-temp-buffer
        (set-buffer (dired-noselect file))
        (dired-do-rename)
        (kill-buffer nil))))
  nil)

(global-set-key "\C-cR" 'rename-current-file-or-buffer)

;; Smartab

(defvar smart-tab-using-hippie-expand nil
  "turn this on if you want to use hippie-expand completion.")

(defun smart-tab (prefix)
  "Needs `transient-mark-mode' to be on. This smart tab is
minibuffer compliant: it acts as usual in the minibuffer.

In all other buffers: if PREFIX is \\[universal-argument], calls
`smart-indent'. Else if point is at the end of a symbol,
expands it. Else calls `smart-indent'."
  (interactive "P")
  (if (minibufferp)
      (minibuffer-complete)
    (if (smart-tab-must-expand prefix)
        (if smart-tab-using-hippie-expand
            (hippie-expand nil)
          (dabbrev-expand nil))
      (smart-indent))))

(defun smart-indent ()
  "Indents region if mark is active, or current line otherwise."
  (interactive)
  (if mark-active
      (indent-region (region-beginning)
                     (region-end))
    (indent-for-tab-command)))

(defun smart-tab-must-expand (&optional prefix)
  "If PREFIX is \\[universal-argument], answers no.
Otherwise, analyses point position and answers."
  (unless (or (consp prefix)
              mark-active)
    (looking-at "\\_>")))

;; Enable smartab for perl files
(add-hook 'cperl-mode-hook
          (lambda ()
            (local-set-key (kbd "<tab>") 'smart-tab)
            ))

;; Enable smartab for html files
(add-hook 'html-mode-hook
          (lambda ()
            (local-set-key (kbd "<tab>") 'smart-tab)
            ))


;; Revert buffer
(global-set-key "\C-xrr" 'revert-buffer)

;; Grep in workspace
(grep-compute-defaults)
(defvar workspace-dir '"~/working/workspace")
(defun grep-in-workspace (pattern)
  "Run `rgrep' in all files of `wokspace-dir' for the given PATTERN."
  (interactive "sGrep pattern: ")
  (rgrep pattern "*" workspace-dir))

(global-set-key "\C-xgs" 'grep-in-workspace)

;; Find in workspace
(defun find-in-workspace (pattern)
  "Run `find-name-dired' in `workspace-dir'."
  (interactive "sFilename wildcard: ")
  (find-name-dired workspace-dir pattern))

;; Save backups in backups_folder
(defvar user-temporary-file-directory "~/.emacs_backups/")
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

;; Enable columns numbers
(setq column-number-mode t)

;; Encryption
(require 'epa-file)
(epa-file-enable)

;; Pretty print xml
(defun bf-pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t)
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

;; Renaming
;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
    (filename (buffer-file-name)))
    (if (not filename)
    (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
      (message "A buffer named '%s' already exists!" new-name)
    (progn
      (rename-file name new-name 1)
      (rename-buffer new-name)
      (set-visited-file-name new-name)
      (set-buffer-modified-p nil))))))

;; Customize scheme
;(set-background-color "black") ; Uncomment to avoid transparent background and get a *nice* solid colour
;;(set-foreground-color "white")
;;(set-cursor-color "white")
;;(set-face-foreground 'region "black")
;;(set-face-background 'region "white")
;;(set-face-foreground 'modeline "white")
;;(set-face-background 'modeline "red")
;;(set-face-foreground 'isearch "white")
;;(set-face-background 'isearch "red")
;;(set-face-background 'isearch-lazy-highlight-face "white")
;;(set-face-background 'isearch-lazy-highlight-face "red")

(custom-set-faces
'(region ((t (:background "#2a2a2a"))))
'(font-lock-comment-face ((t (:foreground "#44444e" :slant italic ))))
'(font-lock-string-face ((t (:foreground "#66bb00" ))))
'(font-lock-keyword-face ((t (:foreground "#ff6600" ))))
'(font-lock-variable-name-face ((t (:foreground "#5251ce" ))))
'(font-lock-type-face ((t (:foreground "#339999" :weight bold))))
'(font-lock-function-name-face ((((class color)) (:foreground "#eebb00" :weight bold))))
'(show-paren-match-face ((((class color)) ( :background "#343474"))))
'(font-lock-constant-face  ((((class color)) (:foreground "#339999" :weight bold))))
'(cperl-nonoverridable-face ((t (:foreground "#339999" :weight bold))))
'(cperl-array-face ((t (:foreground "#5251ce" :weight bold))))
'(cperl-hash-face ((t (:foreground "#5251ce" :weight bold))))
'(which-func ((t (:foreground "#999999" :weight bold))))
)

;; Enable which function mode
(add-hook 'cperl-mode-hook
          (lambda ()
            (which-function-mode t)))

;; ETAGS
(visit-tags-table "~/working/workspace/wctperl/TAGS")

;; Convert line endings to UNIX allways for cperl-files
(add-hook 'before-save-hook
          (lambda ()
            (set-buffer-file-coding-system 'unix)))
