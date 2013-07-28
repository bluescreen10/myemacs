;; Load path
;;(add-to-list 'load-path "~/.emacs.d")  

;; Repositories
(setq package-archives
  '(("melpa" . "http://melpa.milkbox.net/packages/")))

;; Packages
(require 'package)
(package-initialize)

;; Look and feel
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-highlight-variables-indiscriminately t)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(cperl-invalid-face nil)
 '(cperl-tab-always-indent t)
 '(org-agenda-files (quote ("~/workspace/org/agenda.org")))
 '(scalable-fonts-allowed t)
 '(show-paren-mode t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "grey12" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 90 :width normal :family "Droid Sans Mono"))))
 '(cperl-array-face ((t (:foreground "white"))))
 '(cperl-hash-face ((t (:foreground "white"))))
 '(cperl-nonoverridable-face ((t (:foreground "cyan3" ))))
 '(cursor ((t (:background "#e09800"))))
 '(font-lock-builtin-face ((t (:foreground "deep pink" ))))
 '(font-lock-comment-face ((t (:foreground "#998" ))))
 '(font-lock-constant-face ((((class color)) (:foreground "#009926"))))
 '(font-lock-function-name-face ((((class color)) (:foreground "chartreuse"))))
 '(font-lock-keyword-face ((t (:foreground "deep pink" ))))
 '(font-lock-string-face ((t (:foreground "khaki"))))
 '(font-lock-type-face ((t (:foreground "deep pink" ))))
 '(font-lock-variable-name-face ((t (:foreground "white"))))
 '(fringe ((t (:foreground "grey12"))))
 '(hl-line ((t (:background "grey16"))))
 '(mode-line ((t (:foreground "#eee" :background "#333"))))
 '(mode-line-buffer-id ((t (:foreground "#fff" ))))
 '(mode-line-inactive ((t (:foreground "#eee" :background "#666"))))
 '(region ((t (:background "grey4"))))
 '(show-paren-match ((((class color)) (:background "#bbb"))))
 '(underline ((t (:foreground "#999" :underline t))))
 '(which-func ((t (:foreground "#e09800" )))))

;; Hi-line
(global-hl-line-mode 1)

;;(load  "~/.emacs.d/cperl-mode.el")
(setq cperl-hairy nil)
;;(setq cperl-electric-parens nil)

;; Cperl
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist (append (list (cons "\\.\\(psgi\\|t\\|cgi\\|psgi\\)$" 'cperl-mode)) auto-mode-alist))
(add-to-list 'auto-mode-alist '("cpanfile" . cperl-mode))

;; Use 4 space indents via cperl mode


;; Insert spaces instead of tabs
(setq-default indent-tabs-mode nil)

(global-set-key [(control /)] 'comment-or-uncomment-region)

;; Load path
(add-to-list 'load-path "~/.emacs.d")  

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

;; Enable smartab for java files
(add-hook 'jde-mode-hook
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

;; Tramp
(setq tramp-default-host "localhost")

;; Enable columns numbers
(setq column-number-mode t)


;;Orgmode
(require 'org)
(setq org-todo-keyword-faces
      '(
        ("WORKING" . (:foreground "orange" :weight bold))
        ("WAIT"    . (:foreground "grey" :weight bold))
        ))

;; Encryption
(require 'epa-file)
(epa-file-enable)

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


;; Enable which function mode
(add-hook 'cperl-mode-hook
          (lambda ()
            (which-function-mode t)))

;; Convert line endings to UNIX allways for cperl-files
(add-hook 'before-save-hook
          (lambda ()
            (set-buffer-file-coding-system 'unix)))

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-font-lock-mode 1)


(put 'narrow-to-region 'disabled nil)
(put 'set-goal-column 'disabled nil)

;; Do not show GNU splash screen
(setq inhibit-startup-message t)

(add-hook 'vc-post-command-functions 'tags-vc-hook)

;; Load project extension
(load "~/.emacs.d/ellipse.el")

;; PMC
(add-to-list 'auto-mode-alist '("\\.pmc$" . c-mode))

;; PSVN
;; (require 'psvn)

;; Clipboard
(setq x-select-enable-clipboard t)

;; Perlbrew
(require 'perlbrew-mini)
(perlbrew-mini-use "perl-5.14.2")

;; Multi-web-mode
(require 'multi-web-mode)
(setq mweb-default-major-mode 'html-mode)
(setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
                  (js-mode "<script +\\(type=\"text/javascript\"\\|language=\"javascript\"\\)[^>]*>" "</script>")
                  (css-mode "<style +type=\"text/css\"[^>]*>" "</style>")))
(setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "pap5"))
(multi-web-global-mode 1)


;; Helm
(require 'helm)
(require 'helm-config)
(require 'helm-cmd-t)
(global-set-key (kbd "M-t") 'helm-projectile)

;; Multiple Cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
