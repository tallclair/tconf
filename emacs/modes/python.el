;;
;; Python settings
;;

;; https://github.com/jorgenschaefer/elpy/wiki/Installation

(use-package elpy
  :ensure t
  :config
  (add-hook 'python-mode-hook 'flycheck-mode)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (setq elpy-rpc-python-command "python3")
  (setq exec-path (cons (concat (getenv "HOME") "/.local/bin") exec-path))
  (elpy-enable)
  )
