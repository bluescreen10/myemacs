;;; mimic.el --- Upload files when modified
;;

;; TODO
;; * Partial upload
;; * Timeouts
;;
;; Change log - 1.5 -
;; * Isolated config from mimic.el put all sites in a file located at ~/.mimic
;;


;; Sample config file ~/.mimic
;;
;; (add-to-list 
;;  'mimic-locations 
;;  '(source
;;    destination
;;    partial sync => t , full sync => nil
;;    ssh special options
;;    rsync exclude file
;;    remote rsync command location))                 


;; Clean Project locations
(setq mimic-locations '())

;; Rsync command
(setq mimic-command "/usr/bin/rsync")

;; upload file hook
(defun mimic-upload(resource)
  (let ((index 0)
        (number-of-locations (length mimic-locations)))
        (while (< index number-of-locations)
          (when (string-match (file-truename (car (nth index mimic-locations))) (file-truename resource))
   
            ;; Parse config
            (let 
                ((source               (file-truename (nth 0 (nth index mimic-locations))))
                 (destination          (nth 1 (nth index mimic-locations)))
                 (partial              (nth 2 (nth index mimic-locations)))
                 (ssh-options          (nth 3 (nth index mimic-locations)))
                 (exclude-file         (nth 4 (nth index mimic-locations)))
                 (remote-rsync-command (nth 5 (nth index mimic-locations)))
                 (command '()))

              ;; Source and destination (Order matters)
              (add-to-list 'command destination)
              (add-to-list 'command source)

              (message (format "Synchronizing %s..." source ))

              ;; Remote rsync command
              (if remote-rsync-command
                  (add-to-list 'command (format "--rsync-path=%s" remote-rsync-command)))

              ;; Exclude file
              (if exclude-file
                  (add-to-list 'command (format "--exclude-from=%s" (file-truename exclude-file))))

              ;; Ssh options
              (if ssh-options
                  (add-to-list 'command (format "ssh %s" ssh-options))
                  (add-to-list 'command "ssh"))
              (add-to-list 'command "-e")

              ;; Set up command and buffers
              (add-to-list 'command "-z")
              (add-to-list 'command "-r")
              (add-to-list 'command "-t")
              (add-to-list 'command "--inplace")
              (add-to-list 'command mimic-command)
              (add-to-list 'command "*mimic*")
              (add-to-list 'command "mimic")

              ;; Launch process
              (apply 'start-process command)
              (set-process-filter (get-process "mimic") 'mimic-prompt-password-filter)
              (set-process-sentinel (get-process "mimic") 'mimic-process-sentinel)))
          ;; Increment the index
          (setq index (+ index 1)))))

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


;; Mimic prompt password filter
(defun mimic-prompt-password-filter (proc str)
  (print str (get-buffer "*mimic*"))
  (if (string-match "[Pp]ass\\(word\\|phrase\\).*:\\s *\\'" str)
  (progn
    (process-send-string proc (format "%s\n" (read-passwd str))))))

;; Mimic process sentinel
(defun mimic-process-sentinel (proc event)
  (message "")
  (if (string-match "abnormally" event)
      (message "Finished with errors")))

;;; Load config
(setq mimic-config-file "~/.mimic")
(if (file-readable-p mimic-config-file)
    (load mimic-config-file))

;;; mimic.el ends here
