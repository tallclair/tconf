;;
;; Set up shared packages
;;

;; From http://stackoverflow.com/questions/10092322/how-to-automatically-install-emacs-packages-by-specifying-a-list-of-package-name

;; list the packages you want
(setq package-list
  '(
     ag
     company
     company-go
     company-lsp
     dash
     epl
     exec-path-from-shell
     flycheck
     go-mode
     haskell-mode
     let-alist
     lsp-mode
     lsp-ui
     pkg-info
     popup
     rich-minority
     s
     smart-mode-line
     solarized-theme
     use-package
     ))

;; list the repositories containing them
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))

;; activate all the packages (in particular autoloads)
(package-initialize)

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Bootstrap use-package
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
