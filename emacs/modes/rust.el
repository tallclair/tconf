(use-package rust-mode
  :ensure t
  :config
  (progn
    (use-package racer
      :ensure t
      :config
      (setq racer-rust-src-path "/home/martin/rustc/rustc-1.7.0/src/"))
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (add-hook 'racer-mode-hook #'company-mode)
    (setq rust-format-on-save t)))
