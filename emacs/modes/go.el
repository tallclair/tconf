;;
;; Go settings
;;

;; SETUP:
;; go {get,install} github.com/rogpeppe/godef  # jump to definition

;; Useful bindings:
;;  C-c C-j  Jump to definition
;;  C-c C-d  Describe symbol

;; (use-package go-mode
;;   :ensure t
;;   :config
;;   (add-hook 'go-mode-hook 'flycheck-mode)
;;   (add-hook 'go-mode-hook 'company-mode)
;;   (add-hook 'before-save-hook 'gofmt-before-save)
;;   (setq gofmt-command "goimports")
;;   (setq go-command "go"))

;; (use-package go-guru
;;   :ensure t
;;   :config
;;   (setq go-guru-command "guru")) ;; FIXME - set absolute path
;; (use-package go-rename
;;   :ensure t)



;;;;;; EXPERIMENTAL ;;;;;;;;



;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Company mode is a standard completion package that works well with lsp-mode.
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

;; company-lsp integrates company mode completion with lsp-mode.
;; completion-at-point also works out of the box but doesn't support snippets.
(use-package company-lsp
  :ensure t
  :commands company-lsp)

;; (lsp-register-custom-settings
;;  '(("gopls.staticcheck" t t)))
