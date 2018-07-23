;; Utilities for navigating related files

(defun related-build-file()
  "Opens the BUILD file for the current buffer file."
  (interactive)
  (unless (find-file-existing (concat (file-name-directory (buffer-file-name)) "BUILD"))
    (message "Corresponding BUILD file not found")))


(defun related-test-file ()
  "Opens the corresponding test file for a source, or source file for a test."
  (interactive)
  (let* ((name (file-name-nondirectory (file-name-sans-extension (buffer-file-name))))
         (is-test (string-match ".*[Tt]est$" name)))
    (related-test-file-other (buffer-file-name) is-test)))


(defun related-test-file-other (relpath is-test)
  "Opens the corresponding test file for a java source, or source file for a java test"
  (let* ((base-name (file-name-sans-extension relpath))
         (extension (file-name-extension relpath))
         (target-extension (cond ((member extension '("cc" "h")) "cc")
                                 ('ELSE extension)))
         (path-matcher-regex (if is-test "\\(.*\\)_test" "\\(.*\\)"))
         (path-replacer-string (if is-test "\\1" "\\1_test")))
    (when (string-match path-matcher-regex base-name)
      (let ((corresponding-relpath (concat (replace-match path-replacer-string nil nil base-name)
                                           "." target-extension)))
        (unless (find-file-existing corresponding-relpath)
          (message "Corresponding file does not exist: %s" corresponding-relpath))))))

;; Custom key bindings
;; (global-set-key (kbd "M-s c") 'csearch)
(defun bind-related-file-keys ()
  (local-set-key (kbd "C-c r t") 'related-test-file)
  (local-set-key (kbd "C-c r b") 'related-build-file))
(add-hook 'prog-mode-hook 'bind-related-file-keys)

(provide 'related-files)
