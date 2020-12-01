(defun bk/occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (if (region-active-p)
            (buffer-substring-no-properties
             (region-beginning)
             (region-end))
          (let ((sym (thing-at-point 'symbol)))
            (when (stringp sym)
              (regexp-quote sym))))
        regexp-history)
  (call-interactively 'occur))

(global-set-key (kbd "M-s o") 'bk/occur-dwim)


(defun bk/kill-inner-word ()
  "Kill the entire word your cursor is in.  Equivalent to ciw in vim."
  (interactive)
  (forward-char 1)
  (backward-word)
  (kill-word 1))

(global-set-key (kbd "C-c k w") 'bk/kill-inner-word)


(defun bk/copy-whole-line ()
  "Copy a line without regard for cursor position."
  (interactive)
  (save-excursion
    (kill-new
     (buffer-substring
      (point-at-bol)
      (point-at-eol)))))

(global-set-key (kbd "C-c y l") 'bk/copy-whole-line)


(defun duplicate-region (num &optional start end)
  "Duplicate the region bounded by START and END NUM times."
  (interactive "p")
  (let* ((start (or start (region-beginning)))
         (end (or end (region-end)))
         (region (buffer-substring start end)))
    (goto-char start)
    (dotimes (_ num)
      (insert region))))

(defun duplicate-current-line (num)
  "Duplicate the current line NUM times."
  (interactive "p")
  (when (eq (point-at-eol) (point-max))
    (goto-char (point-max))
    (newline)
    (forward-char -1))
  (duplicate-region num (point-at-bol) (1+ (point-at-eol))))

(defun bk/duplicate-current-line-or-region (arg)
  "Duplicate the current line or region ARG times."
  (interactive "p")
  (save-excursion
    (if (region-active-p)
        (duplicate-region arg)
      (duplicate-current-line arg))))

(global-set-key (kbd "C-c 2") #'bk/duplicate-current-line-or-region)

(defun bk/eval-buffer ()
  "Provide some feedback after evaluating the buffer."
  (interactive)
  (eval-buffer)
  (message "Buffer evaluated!"))

(define-key emacs-lisp-mode-map (kbd "C-c C-k") 'bk/eval-buffer)


;;; improve scroll functions
(defun bk/scroll-up ()
  "Scroll only specific amount of lines."
  (interactive)
  (scroll-up-command 8))

(global-set-key (kbd "C-v") #'bk/scroll-up)

(defun bk/scroll-down ()
  "Scroll only specific amount of lines."
  (interactive)
  (scroll-down-command 8))

(global-set-key (kbd "M-v") #'bk/scroll-down)

(defun bk/beginning-of-line ()
  "Go back at the first non-whitespace character."
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

(global-set-key (kbd "C-a") 'bk/beginning-of-line)

(defun bk/end-of-line ()
  "Go to the end of the last non-whitespace character."
  (interactive)
  (move-end-of-line nil)
  (re-search-backward "^\\|[^[:space:]]")
  (forward-char))

(global-set-key (kbd "C-e") 'bk/end-of-line)


(defun bk/nrepl-warn-when-not-connected ()
  "Function to warn me to start the REPL."
  (interactive)
  (message "Oops! You're not connected to an nREPL server.
Please run M-x cider or M-x cider-jack-in to connect"))


(defun bk/kill-buffer ()
  "Kill current buffer."
  (interactive)
  (kill-buffer (current-buffer)))

(global-set-key (kbd "C-x k") 'bk/kill-buffer)

(defun bk/kill-buffer-and-file (buffer-name)
  "Remove file connected to current buffer and kill the BUFFER-NAME."
  (interactive "bKill buffer and its file: ")
  (let* ((buffer (get-buffer buffer-name))
         (filename (buffer-file-name buffer)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" buffer-name)
      (delete-file filename)
      (kill-buffer buffer))))

(defun bk/toggle-window-split ()
  "Toggle window."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter (if (= (car this-win-edges)
                              (car (window-edges (next-window))))
                           'split-window-horizontally
                         'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-c |") 'bk/toggle-window-split)

(defun bk/vsplit-last-buffer ()
  "Split the window vertically and display the previous buffer."
  (interactive)
  (split-window-vertically)
  (other-window 1 nil)
  (switch-to-next-buffer))

(global-set-key (kbd "C-x 2") 'bk/vsplit-last-buffer)

(defun bk/hsplit-last-buffer ()
  "Split the window horizontally and display the previous buffer."
  (interactive)
  (split-window-horizontally)
  (other-window 1 nil)
  (switch-to-next-buffer))

(global-set-key (kbd "C-x 3") 'bk/hsplit-last-buffer)


(defun server-shutdown ()
  "Save buffers, quit, and shutdown server"
  (interactive)
  (save-some-buffers)
  (kill-emacs))

(defun lgm/clock-in-when-started ()
  "Automatically clock in a task when status is changed to STARTED."
  (when (string= org-state "STARTED")
    (org-clock-in)))

(defun bk/clock-out-when-waiting ()
  "Clock out when the task change to WAIT."
  (when (and (string= org-state "WAIT")
             (not (string= org-last-state org-state)))
    (org-clock-out)))

(defun bk/jump-to-register ()
  "Switch between current position and pos stored."
  (interactive)
  (let ((tmp (point-marker)))
    (jump-to-register 8)
    (set-register 8 tmp)))

(defun bk/point-to-register ()
  "Store cursor position in a register."
  (interactive)
  (point-to-register 8)
  (message "Point set"))

(global-set-key (kbd "C-c r p") 'bk/point-to-register)
(global-set-key (kbd "C-c r j") 'bk/jump-to-register)
