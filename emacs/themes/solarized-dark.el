;; make the fringe stand out from the background
(setq solarized-distinct-fringe-background t)

;; make the modeline high contrast
(setq solarized-high-contrast-mode-line t)

(load-theme 'solarized-dark t)

;; Customize solarized
(solarized-with-color-variables 'dark
  (custom-theme-set-faces 'solarized-dark
    `(helm-ls-git-modified-not-staged-face ((,class (:foreground ,yellow))))
    `(helm-source-header ((,class (:inherit header-line :weight bold))))
  ))
