;; GUI style configuration.

;; Mode-line (status bar)
(set-face-attribute 'mode-line nil
                    :foreground "#ffffff"
                    :background "#009688"
                    :box '(:line-width -1 :color "grey40" :style nil))
(set-face-attribute 'mode-line-inactive nil
                    :foreground "white"
                    :background "gray60"
                    :box '(:line-width -1 :color "grey40" :style nil))

;; Highlighted region
(set-face-attribute 'region nil
                    :foreground "gray10"
                    :background "#ffc400")

;; Highlighted line
(set-face-attribute 'hl-line nil
                    :background "gray95")
