;;; init.el --- My setup to work in the terminal

;;; Commentary:

;; Here be dragons!

;;; Code:

;;; disable cosmetics
(menu-bar-mode -1)

(setq inhibit-startup-screen t
      inhibit-startup-message t)

;; enable show parens
(show-paren-mode +1)

;; Require and initialize `package`.
(require 'package)

;; Add `melpa` to `package-archives`.
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(add-to-list 'package-archives
             '("cselpa" . "https://elpa.thecybershadow.net/packages/"))

(package-initialize)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(use-package diminish
  :ensure t)

(setq custom-theme-directory (concat user-emacs-directory "themes")
      custom-safe-themes t)

(dolist (path (directory-files custom-theme-directory t "\\w+"))
  (when (file-directory-p path)
    (add-to-list 'custom-theme-load-path path)))

(load-theme 'manoj-dark t)

(use-package clojure-mode
  :ensure t
  :config
  (defalias 'cquit 'cider-quit)
  (define-key clojure-mode-map (kbd "C-c M-j") #'cider-jack-in)
  (define-key clojure-mode-map (kbd "C-x C-e") 'bk/nrepl-warn-when-not-connected)
  (define-key clojure-mode-map (kbd "C-c C-k") 'bk/nrepl-warn-when-not-connected)
  (define-key clojure-mode-map (kbd "C-c C-z") 'bk/nrepl-warn-when-not-connected))

(use-package cider
  :ensure t)

(use-package clj-refactor
  :ensure t
  :diminish clj-refactor-mode
  :init
  (setq cljr-warn-on-eval nil)
  :config
  (add-hook 'clojure-mode-hook #'clj-refactor-mode)
  (cljr-add-keybindings-with-prefix "C-c C-m"))

(use-package tramp
  :config
  (setq projectile-mode-line "Projectile"))

(use-package eldoc
  :diminish eldoc-mode
  :config
  (global-eldoc-mode +1))

;;; haskell
(use-package haskell-mode
  :ensure t
  :config
  (define-key haskell-mode-map [f8] 'haskell-navigate-imports)
  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  (add-hook 'haskell-mode-hook 'haskell-doc-mode))

(use-package lsp-mode
  :ensure t)

(use-package lsp-haskell
  :ensure t
  :config
  (setq lsp-haskell-server-path "ghcide"
        lsp-haskell-server-args nil))

(use-package flycheck
  :ensure t
  :init
  (setq flycheck-check-syntax-automatically '(mode-enabled save)
        flycheck-display-errors-delay 0.25)
  :config
  (add-hook 'prog-mode-hook #'flycheck-mode))

(use-package flycheck-clj-kondo
  :ensure t
  :after clojure-mode
  :config
  (require 'flycheck-clj-kondo))

(use-package markdown-mode
  :ensure t)

(use-package company
  :ensure t
  :diminish company-mode
  :init
  (setq company-show-numbers t
        company-idle-delay 0.25
        company-echo-delay 0.5
        company-minimum-prefix-length 2
        company-require-match 'never)
  :config
  (global-company-mode t))

(use-package magit
  :ensure t
  :init
  (set-default 'magit-revert-buffers 'silent)
  (set-default 'magit-no-confirm '(stage-all-changes
                                   unstage-all-changes))
  (setq magit-save-repository-buffers t
        magit-auto-revert-mode t
        global-magit-file-mode t ;; enables C-x g, C-x M-g, C-c M-g
        )
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  )

(use-package git-timemachine
  :ensure t)

(use-package paredit
  :ensure t
  :diminish paredit-mode
  :config
  (define-key paredit-mode-map (kbd "M-s") nil)
  (define-key paredit-mode-map (kbd "M-r") nil)
  (define-key paredit-mode-map (kbd "M-?") nil)
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
  (add-hook 'clojure-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook 'paredit-mode))

(use-package ivy
  :ensure t
  :diminish ivy-mode
  :init
  (setq ivy-use-virtual-buffers t
        ivy-case-fold-search-default t
        enable-recursive-minibuffers t
        ivy-initial-inputs-alist nil)
  :config
  (ivy-mode +1))

(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-arguments nil)
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

(use-package counsel
  :ensure t
  :config
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-m") 'counsel-M-x)
  (global-set-key (kbd "C-c i") 'counsel-imenu))

(use-package smex
  :ensure t)

(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))

(use-package change-inner
  :ensure t
  :config
  (global-set-key (kbd "M-i") 'change-inner)
  (global-set-key (kbd "M-o") 'change-outer))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c >") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-c <") 'mc/mark-previous-like-this))

(use-package fix-word
  :ensure t
  :config
  (global-set-key (kbd "M-u") 'fix-word-upcase)
  (global-set-key (kbd "M-l") 'fix-word-downcase)
  (global-set-key (kbd "M-c") 'fix-word-capitalize))

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (projectile-mode 1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package jump-char
  :ensure t
  :config
  (global-set-key (kbd "M-n") 'jump-char-forward)
  (global-set-key (kbd "M-p") 'jump-char-backward))

(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "M-m") #'avy-goto-char))

(use-package dired
  :config
  (require 'dired-x)
  (global-set-key (kbd "C-x C-j") 'dired-jump))

(use-package command-log-mode
  :ensure t)

(use-package whitespace-cleanup-mode
  :ensure t
  :diminish whitespace-cleanup-mode
  :config
  (whitespace-cleanup-mode +1))

(use-package winner
  :init
  (setq winner-dont-bind-my-keys t
        winner-boring-buffers
        '("*Completions*"
          "*Compile-Log*"
          "*inferior-lisp*"
          "*Fuzzy Completions*"
          "*Apropos*"
          "*Help*"
          "*cvs*"
          "*Buffer List*"
          "*Ibuffer*"
          "*esh command on file*"))
  :config
  (winner-mode +1)
  (global-set-key (kbd "C-x 4 u") 'winner-undo)
  (global-set-key (kbd "C-x 4 U") 'winner-redo))

;; add the system clipboard to the emacs kill-ring
(setq save-interprogram-paste-before-kill t)

;; complete
(setq tab-always-indent 'complete)

;;; basics
(setq tab-always-indent 'complete
      vc-follow-symlinks t
      create-lockfiles nil
      backup-directory-alist `(("." . ,(expand-file-name
                                        (concat user-emacs-directory "backups")))))

;;; start recentf
(recentf-mode +1)

;;; visible bell
(setq visible-bell nil
      ring-bell-function nil)

;;; uniquify
(setq uniquify-buffer-name-style 'post-forward-angle-brackets
      uniquify-separator " * "
      uniquify-after-kill-buffer-p t
      uniquify-strip-common-suffix t
      uniquify-ignore-buffers-re "^\\*")

;;; go back to last marked place
(global-set-key (kbd "C-x p") 'pop-to-mark-command)

;;; abbreviate yes-or-no questions
(fset 'yes-or-no-p 'y-or-n-p)

;;; don't use tabs to indent
(setq-default indent-tabs-mode nil)

;;; move between window
(windmove-default-keybindings)

(use-package windresize
  :ensure t)

;;; advices
(defadvice pop-to-mark-command (around ensure-new-position activate)
  (let ((p (point)))
    (when (eq last-command 'save-region-or-current-line)
      ad-do-it
      ad-do-it
      ad-do-it)
    (dotimes (i 10)
      (when (= p (point)) ad-do-it))))

;;; load functions
(load-file (expand-file-name "functions.el" user-emacs-directory))

;;; load tmux translations
(load-file (expand-file-name "tmux-translation.el" user-emacs-directory))

;;; amazing hack using urxvt
(if (string-equal (system-name) "tomato")
    (global-set-key (kbd "<f7>") 'backward-kill-word)
  (global-set-key (kbd "C-<delete>") 'backward-kill-word))


;;; fix kill rings
(setq save-interprogram-paste-before-kill t
      x-select-enable-clipboard t
      select-enable-clipboard t)

(use-package xclip
  :ensure t
  :config
  (xclip-mode +1))

;;; programming mode
(use-package hl-todo
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'hl-todo-mode))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config
  (yas-global-mode +1)
  (define-key yas-minor-mode-map [(tab)] nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-c y") #'yas-expand))

(use-package yasnippet-snippets
  :ensure t)

;;; moving between tmux panes
(defun bk/windmove (windmove-fn tmux-param)
  "Base function to move windows from WINDMOVE-FN or using TMUX-PARAM."
  (interactive)
  (condition-case nil
      (funcall windmove-fn)
    (error (shell-command (concat "tmux select-pane " tmux-param)))))

(defun bk/windmove-up ()
  "Move up."
  (interactive)
  (bk/windmove 'windmove-up "-U"))

(defun bk/windmove-down ()
  "Move down."
  (interactive)
  (bk/windmove 'windmove-down "-D"))

(defun bk/windmove-left ()
  "Move left."
  (interactive)
  (bk/windmove 'windmove-left "-L"))

(defun bk/windmove-right ()
  "Move right."
  (interactive)
  (bk/windmove 'windmove-right "-R"))

(global-set-key (kbd "S-<down>") 'bk/windmove-down)
(global-set-key (kbd "S-<up>") 'bk/windmove-up)
(global-set-key (kbd "S-<left>") 'bk/windmove-left)
(global-set-key (kbd "S-<right>") 'bk/windmove-right)

(use-package term-keys
  :ensure t
  :config
  (term-keys-mode t)
  (defun bk/setup-Xresources ()
    (interactive)
    (require 'term-keys-urxvt)
    (with-temp-buffer
      (insert (term-keys/urxvt-xresources))
      (append-to-file (point-min) (point-max) "~/.Xresources"))))


(setq org-duration-format (quote h:mm))

(use-package ox-reveal
  :ensure t
  :config
  (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#3c3836" "#fb4934" "#b8bb26" "#fabd2f" "#83a598" "#d3869b" "#8ec07c" "#ebdbb2"])
 '(custom-safe-themes
   '("b89ae2d35d2e18e4286c8be8aaecb41022c1a306070f64a66fd114310ade88aa" "aded61687237d1dff6325edb492bde536f40b048eab7246c61d5c6643c696b7f" default))
 '(package-selected-packages
   '(monokai lsp-haskell lsp-mode ghc-modi ghc-mod ghc hindent haskell-mode ox-reveal org-reveal org-re-reveal term-keys windresize org-roam ob-clojure yasnippet-snippets hl-todo markdown-mode xclip default-text-scale diminish monokai-theme better-defaults cider clojure-mode use-package))
 '(safe-local-variable-values
   '((TeX-command-extra-options . "-shell-escape")
     (cider-cljs-lein-repl . "(do (user/go) (user/cljs-repl))")
     (cider-ns-refresh-after-fn . "reloaded.repl/resume")
     (cider-ns-refresh-before-fn . "reloaded.repl/suspend"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
;;; init.el ends here
