(defpackage "skk" (:use "lisp" "editor"))
(in-package "skk")

;; skk/skk.l

(export '(*skk-mode-hook*
          *skk-show-annotation*
          *skk-annotation-function*
          *skk-minibuff-map*
          *skk-init-file*
          *j-special-midashi-char-list*
          *j-henkan-okuri-strictly*
          *skk-kakutei-jisyo*
          *skk-initial-search-jisyo*
          *skk-large-jisyo*
          *skk-aux-large-jisyo*
          *skk-search-prog-list*
          *skk-jisyo*
          *skk-backup-jisyo*
          *skk-jisyo-code*
          *skk-record-file*
          *skk-kakutei-key*
          *skk-date-ad*
          *skk-number-style*
          *skk-keep-record*
          *skk-auto-okuri-process*
          *skk-process-okuri-early*
          *skk-egg-like-newline*
          *skk-kakutei-early*
          *j-henkan-show-candidates-keys*
          *skk-mode-string*
          *skk-hirakana-mode-string*
          *skk-katakana-mode-string*
          *skk-zenei-mode-string*
          *skk-echo*
          *skk-server-host*
          *skk-serv*
          *skk-server-list*
          *skk-portnum*
          *skk-report-server-response*
          *skk-use-numeric-conversion*
          *skk-dabbrev-like-completion*
          *skk-delete-implies-kakutei*
          *skk-delete-okuri-when-quit*
          *skk-num-type-list*
          *skk-char-type-vector*
          *skk-kana-rom-vector*
          *skk-prefix-list*
          *skk-rom-kana-rule-list*
          *skk-rom-kana-rule-tree*
          *skk-roma-kana-a*
          *skk-roma-kana-i*
          *skk-roma-kana-u*
          *skk-roma-kana-e*
          *skk-roma-kana-o*
          *skk-input-vector*
          *skk-zenkaku-vector*
          *skk-auto-fill-mode-hook*
          skk-version
          skk-server-version
          skk-auto-fill-mode
          skk-mode
          skk-kill-xyzzy-without-saving-jisyo
          skk-save-jisyo))

(let ((m "skk/skk"))
  (autoload 'skk-mode m t)
  (autoload 'skk-auto-fill-mode m t))

;; skk/skk-gadget.l

(let ((m "skk/skk-gadget"))
  (autoload 'make-string m nil t)
  (autoload 'current-time-string m)
  (autoload 'pwd m)
  (autoload 'skk-current-date m)
  (autoload 'skk-default-current-date m)
  (autoload 'skk-gengo-to-ad m)
  (autoload 'skk-ad-to-gengo m)
  (autoload 'skk-calc m)
  (autoload 'skk-gadget-units-conversion m nil t)
  (autoload 'skk-plus m)
  (autoload 'skk-minus m)
  (autoload 'skk-times m))

(provide "skk/autoloads")
