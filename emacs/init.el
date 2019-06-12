;;
;; Global configurations
;;

;; UI settings
(menu-bar-mode 0)                   ;; disable the menubaar
(when window-system
    (tool-bar-mode 0)               ;; disable the toolbar
    (scroll-bar-mode 0))            ;; disable scrollbars
(setq inhibit-startup-screen t)     ;; don't show welcome screen
(setq inhibit-splash-screen t)      ;; don't show splash screen
(setq initial-scratch-message "")   ;; empty initial scratch buffer

;; Define some functions
(defun rel-path (relative-path)  ;; TODO replace with (file-relative-name)
  "Return the full path of RELATIVE-PATH, relative to this function call."
  (concat (file-name-directory (or load-file-name buffer-file-name)) relative-path))

;; Load packages
(load (rel-path "packages.el"))

;; UI styles
(load (rel-path "style.el"))

;; Grab $PATH from bash
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)
(defvaralias 'js-indent-level 'tab-width)

;; Show bad ws
;; (require 'whitespace)
;; (setq show-ws-toggle-show-trailing-whitespace t)
;; (setq show-ws-toggle-show-tabs t)
(setq-default show-trailing-whitespace t)

(toggle-uniquify-buffer-names)

;; Column numbers
(column-number-mode 1)

;; For hi-lighted parens
(load-library "paren")

;; Default line length is 100 chars
(setq-default fill-column 100)
(setq-default comment-fill-column 80)

;; Require a final newline in a file, to avoid confusing some tools
(setq require-final-newline t)

;; Minibuffer settings
(setq
  enable-recursive-minibuffers nil       ;;  allow mb cmds in the mb
  max-mini-window-height .25             ;;  max 2 lines
  minibuffer-scroll-window nil
  resize-mini-windows nil)

;; Ignore case when using completion for file names:
(setq read-file-name-completion-ignore-case t)

;; Enable some disabled functions
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Use y-n instead of yes-no for prompts
(defalias 'yes-or-no-p 'y-or-n-p)

;; Move to wrapped lines
(setq line-move-visual t)

;; Automatically revert file if it's changed on disk:
(global-auto-revert-mode 1)
;; be quiet about reverting files
(setq auto-revert-verbose nil)

;;
;; Keybindings
;;

(global-set-key (kbd "C-x g") 'goto-line)
(global-set-key (kbd "C-c C-f") 'fill-paragraph)  ;; wrap comments to fill-column length
(global-set-key (kbd "C-c r h") 'ff-find-other-file)  ;; toggle .cc and .h files
(global-set-key (kbd "C-c c") 'comment-region)

;; Unbind annoying commands.
(global-unset-key (kbd "C-z"))      ;; Never stop on C-z
(global-unset-key (kbd "C-x C-l"))  ;; downcase-region

;;
;; Load plugins
;;

;; Always use flycheck
;;(add-hook 'after-init-hook #'global-flycheck-mode)

;; Load configuration modules.
(load (rel-path "major-modes.el"))

;;
;; Create directories for backup / autosave.
;;

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(defvar autosave-dir "~/.emacs.d/autosaves/")
(defun set-autosave-dir (dir)
  "Set the autosave directory location"
  (setq autosave-dir dir)
  (make-directory autosave-dir t))
(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))
(defun make-auto-save-file-name ()
  (concat autosave-dir
   (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
    (expand-file-name
     (concat "#%" (buffer-name) "#")))))

;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir "~/.emacs.d/backups/")
(defun set-backup-dir (dir)
  "Set the backup directory location"
  (setq backup-dir dir)
  (make-directory backup-dir t)
  (setq backup-directory-alist (list (cons "." backup-dir))))

;; Disable backups for remote files.
;; TODO: backup to the remote location
(setq backup-enable-predicate
      (lambda (name)
        (and (normal-backup-enable-predicate name)
             (not (string-match tramp-file-name-regexp name)))))

;; Disable auto save for remote files.
(use-package tramp
  :config
  (defun tramp-set-auto-save ()
    (auto-save-mode -1)))

;; Open URLs in chrome
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome")

;; Open use view-mode with read-only buffers.
(setq-default view-read-only t)

;;
;; General programming settings
;;

;; Load everything in the "modes" directory.
(dolist (mode-file (directory-files (rel-path "modes") t ".*\.el?$"))
  (load mode-file))

;; Load everything in the "custom" directory
(dolist (mode-file (directory-files (rel-path "custom") t ".*\.el?$"))
  (load mode-file))

;; From https://github.com/bbatsov/prelude/blob/master/modules/prelude-programming.el
(defun font-lock-comment-annotations ()
  "Highlight comment annotations."
  (font-lock-add-keywords
   nil '(("\\<\\(\\(FIXME\\|TODO\\|FIXIT\\|WIP\\)\\)\\(\\>\\|:\\)"
          1 font-lock-warning-face t))))
(add-hook 'prog-mode-hook 'font-lock-comment-annotations)


;;
;; Python settings
;;

(add-hook 'python-mode-hook 'flycheck-mode)


;;
;; Haskell settings
;;

;; See http://sritchie.github.io/2011/09/25/haskell-in-emacs/
(use-package haskell-mode
  :defer t
  :config
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-mode-hook 'flycheck-mode)
  (add-hook 'haskell-mode-hook
    (lambda () (eval-after-load 'flycheck '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))))
  ;; Ignore compiled Haskell files in filename completions
  (add-to-list 'completion-ignored-extensions ".hi"))

;;
;; sh-mode settings (shell script)
;;

(setq sh-basic-offset 2)
(setq sh-indentation 2)


;;
;; Packages
;; TODO: Move this section elsewhere
;; haskell-mode
;; flycheck
;; flycheck-haskell
;; go-mode


;; TODO: load local/emacs/init.el && priv/emacs/init.el

;; TODO: Migrate as much as possible to use-package
(use-package company
  :defer t
  :ensure t
  :diminish company-mode
  :init (add-hook 'prog-mode-hook 'company-mode)
  :config
  (bind-keys :map company-mode-map
    ("<tab>" . company-complete-common)))

(use-package magit
  :defer t
  :bind ("M-g M-s" . magit-status)
  :init (setq magit-last-seen-setup-instructions "1.4.0"))

(use-package flycheck
  :defer t
  :diminish flycheck-mode)

(when (executable-find "hunspell")
  (setq-default ispell-program-name "hunspell")
  (setq-default ispell-really-hunspell t))
(use-package flyspell
  :defer t
  :ensure t
  :init
  (add-hook 'markdown-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

(use-package helm
  :ensure t
  :diminish helm-mode
  :init (helm-mode 1)
  :bind ("C-x C-f" . helm-find-files)
  :bind ("M-x" . helm-M-x)
  :config
  (setq
    helm-quick-update t
    helm-idle-delay 0.01
    helm-input-idle-delay 0.01
    helm-exit-idle-delay 0.1))
(use-package helm-ls-git
  :ensure t
  :bind ("C-x C-d" . helm-browse-project))

(use-package web-mode
  :ensure t
  :mode (("\\.html?\\'" . web-mode)
          ("\\.jinja\\'" . web-mode)))
