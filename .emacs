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
 '(scalable-fonts-allowed t)
 '(show-paren-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :foreground "#222" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "unknown" :family "Inconsolata"))))
 '(mode-line ((t (:background "#030" :foreground "#ccc" :box (:line-width -1 :style released-button))))))

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
(defvar workspace-dir '"~/working/workspace2")
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


;;Orgmode
(require 'org-install)

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
(custom-set-faces
 '(region ((t (:background "#fffe73"))))
 '(font-lock-comment-face ((t (:foreground "#3a5fcd" :slant italic ))))
 '(font-lock-string-face ((t (:foreground "#228b22" ))))
 '(font-lock-keyword-face ((t (:foreground "#000080"))))
 '(font-lock-builtin-face ((t (:foreground "#a12600"))))
 '(font-lock-variable-name-face ((t (:foreground "#a12600" ))))
 '(font-lock-type-face ((t (:foreground "#000080" :weight bold))))
 '(font-lock-function-name-face ((((class color)) (:foreground "#e06800"))))
 '(show-paren-match-face ((((class color)) ( :background "#bbb"))))
 '(font-lock-constant-face  ((((class color)) (:foreground "#e06800" :weight bold))))
 '(cperl-nonoverridable-face ((t (:foreground "#000080" :weight bold))))
 '(cperl-array-face ((t (:foreground "#a12600"))))
 '(cperl-hash-face ((t (:foreground "#a12600"))))
 '(underline ((t (:foreground "#999" :underline t))))
 '(which-func ((t (:foreground "#6c0" :weight bold))))
)

;; Enable which function mode
(add-hook 'cperl-mode-hook
          (lambda ()
            (which-function-mode t)))

;; Convert line endings to UNIX allways for cperl-files
(add-hook 'before-save-hook
          (lambda ()
            (set-buffer-file-coding-system 'unix)))

;;Parrot
;;(load-file "~/.emacs.d/parrot.el")


(custom-set-variables
  '(org-agenda-files (quote ("~/working/org/todo.org"))))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-font-lock-mode 1)

;;Run a perl (or others) files
(defun run-current-file ()
  "Execute or compile the current file. For example, if the current buffer is the file x.pl, then it'll call perl x.pl in a shell. The file can be php, perl, python, bash, java.
File suffix is used to determine what program to run."
(interactive)
  (let (ext-map file-name file-ext prog-name cmd-str)
; get the file name
; get the program name
; run it
    (setq ext-map
          '(
            ("php" . "php")
            ("pl" . "perl")
            ("py" . "python")
            ("sh" . "bash")
            ("java" . "javac")
            )
          )
    (setq file-name (buffer-file-name))
    (setq file-ext (file-name-extension file-name))
    (setq prog-name (cdr (assoc file-ext ext-map)))
    (setq cmd-str (concat prog-name " " file-name))
    (shell-command cmd-str)))


(global-set-key (kbd "<f7>") 'run-current-file)
(put 'narrow-to-region 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; Do not show GNU splash screen
(setq inhibit-startup-message t)

;; ETAGS
(setq tags-table-list 
      '("~/TAGS" ))