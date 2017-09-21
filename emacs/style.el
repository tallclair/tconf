;; GUI style configuration.

(when window-system
  (global-hl-line-mode 1)           ;; highlight the current line
  (load-file "~/tconf/themes/current-theme/emacs.el")  ;; Load current theme
  (cond ((member "Source Code Pro" (font-family-list))
          (set-face-attribute 'default nil :font "Source Code Pro-12"))
    ((member "Liberation Mono" (font-family-list))
      (set-face-attribute 'default nil :font "Liberation Mono-12")))
  )
