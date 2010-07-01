;;; mimic.el --- Upload files when modified
;;


; Project locations
(setq mimic-locations '())
(setq mimic-command '"/usr/bin/rsync")


;; upload file hook
(defun mimic-upload(resource)
  (let ((locations (length mimic-locations)))
    (while (> locations 0)
      (setq locations (1- locations))
      (let ((location (file-truename (car (nth locations mimic-locations)))))
	(when (string-match location (file-truename resource))
            (message (format "Synchronizing %s..." location))
            (shell-command (format "%s --rsync-path=/usr/local/bin/rsync --exclude=\".*\" -z -C -r --inplace -e ssh %s %s" 
                         mimic-command 
                         location 
                         (nth 1 (nth locations mimic-locations)))))))))

(defun mimic-vc-command-hook(command file flags)
  (print flags)
  (if (or (string-match "update" (nth 0 flags)) (string-match "update" (nth 0 flags)))
      (if file
	  (mimic-upload file)
	(mimic-upload dir))))

(defun mimic-after-save-hook()
  (mimic-upload buffer-file-name))

;; After save hook
(add-hook 'after-save-hook 'mimic-after-save-hook)
(add-hook 'vc-post-command-functions 'mimic-vc-command-hook)


;;; mimic.el ends here
