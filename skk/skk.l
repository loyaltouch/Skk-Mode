;; SKK (Simple Kana to Kanji conversion program)
;; version 8.6 of May 17, 1995
;; Copyright (C) 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995
;; Masahiko Sato (masahiko@sato.riec.tohoku.ac.jp)

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either versions 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with SKK, see the file COPYING.  If not, write to the Free
;; Software Foundation Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;; Following people contributed modifications to skk.el:
;;      Masakazu Takahashi (masaka-t@ascii.co.jp)
;;      Tsugutomo Enami (enami@ptgd.sony.co.jp)
;;      MORI, Koichi (kmori@onsei2.rilp.m.u-tokyo.ac.jp)
;;      Jun-ichi Nakamura (nakamura@pluto.ai.kyutech.ac.jp)
;;      Kazuo Hirokawa (hirokawa@ricsgw.rics.co.jp)
;;      Wataru Matsui (matsui@atr-rd.atr.co.jp)
;;      Tomoyuki Hiro (hiro@momo.it.okayama-u.ac.jp)
;;      Masahiko Suzuki (suzmasa@sm.sony.co.jp)
;;      Katuya Tomioka (tomioka@culle.l.chiba-u.ac.jp)
;;      Kiyotaka Sakai (ksakai@mtl.t.u-tokyo.ac.jp)
;;      MIYOSHI Tsutomu (minkov@fuzzy.or.jp)
;;      Kazushi Marukawa (kazushi@kubota.co.jp)
;;      Ryoichi Hashimoto (gnu@ipri.go.jp)
;;      Hisao Kuroda (kuroda@msi.co.jp)
;;      Masahiro Doteguchi (xdote@rp.open.cs.fujitsu.co.jp)
;;      Naoki HAMADA (nao@mimo.jaist-east.ac.jp)
;;      Chikanobu Toyofuku (unbound@papaya.juice.or.jp)
;;      Shuji Ashizawa (ashizawa@zuken.co.jp)
;;      GUNJI Takao (gunji@lisa.lang.osaka-u.ac.jp)
;;      IIDA Yosiaki (iida@secom-sis.co.jp)
;;      Kimura Chikahiro (kimura@oa1.kb.nec.co.jp)
;;      Motohiko Mouri (mouri@jaist.ac.jp)
;;      Takeshi OHTANI (ohtani@iias.flab.fujitsu.co.jp)
;;      Haru Mizuno (mizu@cs3.cs.oki.co.jp)
;;      Mikio Nakajima (PBC01764@niftyserve.or.jp)
;;      íÜí√éR çP (hisashi@rst.fujixerox.co.jp)

;; version 8.6 released 1995.5.17
;; version 7.18 released 1994.6.7
;; version 6.32 released 1993.4.24
;; version 5.30 released 1992.5.9
;; version 4.33 released 1991.5.9
;; version 3.47 released 1990.4.29
;; version 2.25 released 1989.4.15
;; version 1.13 released 1988.4.22

;; Xyzzy port
;; Copyright (C) 2005,2006 kia <meshinsha@yahoo.co.jp>
;; Copyright (C) 2006 SANO Masatoshi

;; $Rev: 236 $

(defpackage "skk" (:use "lisp" "editor"))

(in-package "skk")

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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

(defun skk-version ()
  (interactive)
  (if (interactive-p)
      (message "SKK version ~A of May 17, 1995" (skk-version))
    "8.6"))

(defun skk-server-version ()
  (interactive)
  (if (interactive-p)
      (message (skk-server-version))
    (if *skk-server-host*
        (if (skk-dserver-open-p *skk-dserver-connection*)
            (format nil "SKK SERVER ~A running on HOST ~A."
                    (skk-dserver-version *skk-dserver-connection*)
                    (car (skk-dserver-host *skk-dserver-connection*)))
          "SKK SERVER is not active.")
      "You are not using SKK SERVER.")))


;; variable declarations

(defvar *skk-mode-hook* nil)

(defvar *j-count-touroku* 0)
(defvar *j-count-kakutei* 0)

(defvar *j-kakutei-early* nil)
(defvar *j-kakutei-key* nil)

(defvar *skk-isearch-message* nil
  "User must not change the value of this value.  This variable is used in
conjunction with skk-isearch.")

(defvar *j-skk-mode-invoked* nil
  "The value is t if skk-mode was invoked in this Emacs session.")

;; SKK-ANNORTATION related variables.
(defvar *skk-show-annotation* t
  "*Non-nil Ç≈Ç†ÇÍÇŒÅAíêéﬂÇï\é¶Ç∑ÇÈÅB
é´èëÇÃåÛï‚Ç…ä‹Ç‹ÇÍÇÈ `;' à»ç~ÇÃï∂éöóÒÇïœä∑ÇÃç€ÅAíçãLÇ∆ÇµÇƒ\
ÉGÉRÅ[ÉGÉäÉAÅAÇ‹ÇΩÇÕï  Window Ç…ï\é¶Ç∑ÇÈÅB")

(defvar *skk-annotation-function* nil
  "*annotation Çï\é¶Ç∑ÇÈÇ©Ç«Ç§Ç©ÇÃÉ`ÉFÉbÉNéûÇ…ÉRÅ[ÉãÇ≥ÇÍÇÈä÷êîÅB
non-nil Çï‘Ç∑Ç∆ annotation Çï\é¶Ç∑ÇÈÅBannotation ÇÃëŒè€Ç∆Ç∑ÇÈï∂éöóÒ
Çà¯êîÇ…ÇµÇƒ funcall Ç≥ÇÍÇÈÅB")

(defvar-local skk-mode nil
  "The value is t if skk-mode is currently invoked on the current buffer,
it is nil otherwise.")

(defvar-local j-mode-line-format nil
  "Save mode-line-format of the current buffer.  This variable may also be
used to test if skk-mode has been called on the current buffer.")

(defvar-local j-current-local-map nil
  "Save current-local-map")

(defvar-local skk-map nil
  "Keymap for kana mode.")

(defvar-local skk-zenkaku-map nil
  "Keymap for zenkaku mode.")

(defvar-local skk-abbrev-map nil
  "Keymap for abbrev input.")

(defvar *skk-minibuff-map* nil
  "Keymap used when reading string from minibuffer.")

(defvar-local j-emacs-local-map nil
  "Original keymap for emacs mode.")

(defvar-local j-mode-line-skk nil)

(defvar *j-prefix* "")

(defvar-local j-mode nil)

(defvar-local j-henkan-on nil)

(defvar-local j-henkan-start-point nil
  "Henkan start point as a marker.")

(defvar-local j-henkan-end-point nil
  "Henkan end point as a marker.")

(defvar-local j-kana-start-point nil
  "Start point of a kana character as a marker.")

(defvar-local j-okurigana nil
  "If t, it means that okurigana part of henkan word is being input.")

(defvar-local j-okurigana-start-point nil
  "Start point of okurigana")

(defvar-local j-okuri-char ""
  "The roman prefix for the okurigana part of henkan word as a string.")

(defvar-local j-henkan-count 0)

(defvar-local j-okuri-index-min 0)

(defvar-local j-okuri-index-max 0)

(defvar-local j-henkan-active nil)

(defvar-local j-katakana nil
  "t means katakana and nil means hirakana input.")

(defvar-local j-okuri-ari nil)

(defvar-local j-henkan-key nil)

(defvar-local j-henkan-key2 nil)

(defvar-local j-henkan-okurigana nil)

(defvar-local j-henkan-vector (vector))

(defvar *j-jisyo-buffer-modified* nil)

(defvar-local j-search-prog-list nil)

(defvar-local j-zenkaku nil)

(defvar-local j-abbrev nil)

(defvar *j-completion-word* "")

(defvar-local j-num-list ()
  "list of numeric arguments obtained from j-henkan-key.  for instance,
if j-henkan-key is \"2Ç™Ç¬25Ç…Çø\", j-num-list will be set to
(\"2\" \"25\").")

(defvar-local j-search-key nil
  "string used as the search key for midashi search in jisyo buffer. the value
of this variable is set by using j-henkan-key.  for instance, if j-henkan-key
is \"2Ç™Ç¬25Ç…Çø\", j-search-key will be set to \"#Ç™Ç¬#Ç…Çø\".")


;; (defvar *j-remote-shell-program*
;;   (or (si:getenv "REMOTESHELL")
;;       (cond
;;        ((eq system-type 'berkeley-unix) "/usr/ucb/rsh")
;;        ((eq system-type 'usg-unix-v)
;;         (if (file-exists-p "/usr/ucb/remsh") "/usr/ucb/remsh" "/bin/rsh"))
;;        ((eq system-type 'hpux) "/usr/bin/remsh")
;;        ((eq system-type 'EWS-UX/V) "/usr/ucb/remsh")
;;        ((eq system-type 'pcux) "/usr/bin/rcmd")
;;        (t "rsh"))))

(defvar *skk-init-file* "~/.skk"
  "*The name of the skk initialization file.")

(defvar *j-special-midashi-char-list* '(#\> #\< #\?)
  "*List of chars used to spicify pre/post-fixes.")

(defvar *j-henkan-okuri-strictly* nil
  "If non-nil, okurigana should also be matched.")

(defvar *j-kanji-len* (length "Ç†"))

;; constants

;; Customization of these constants cannot be done in .emacs file.  This
;; should be done in .skk file or by using skk-mode-hook.

;; We are using `defconst' rather than `defvar' here for the following
;; reason:  The SKK tutorial program, which is intended for the beginners,
;; must be run on a vanilla SKK.  To achieve this, the tutorial program
;; loads SKK (even if it has been loaded already) and undoes the customization
;; which might have been done by the user.  (Note that `defconst' always sets
;; a new value, while `defvar' does that only when the value is unbound when
;; `defvar' is executed.)

(defvar *skk-kakutei-jisyo* nil
  "*Name of a sorted jisyo file.  If non-nil, the file will be read in a
buffer and will be used to compute henkan candidates.  The file should be
such that each yomi has exactly one candidate.  This file is used by the
function j-search-kakutei-jisyo-file.")

(defvar *skk-initial-search-jisyo* nil
  "*Name of a sorted jisyo file.  If non-nil, the file will be read in a
buffer and will be used to compute henkan candidates.  Normally, this
file will be searched before the user's private jisyo.")

(defvar *skk-large-jisyo* nil
  "*Name of a sorted jisyo file.  If non-nil, the file will be read in a
buffer and will be used to compute henkan candidates.  Normally, the
file be searched after the user's private jisyo.")

(defvar *skk-aux-large-jisyo* nil
  "*Name of a sorted jisyo file.  If non-nil, the file will be used when
skk server is not active.")

(defvar *skk-search-prog-list*
  '(
    (j-search-kakutei-jisyo-file *skk-kakutei-jisyo* 10000 t)
    (j-search-jisyo-file *skk-initial-search-jisyo* 10000 t)
    (j-search-jisyo-file *skk-jisyo* 0 t)
    (j-okuri-search)
    (j-search-jisyo-file *skk-large-jisyo* 10000)
    (j-search-server *skk-aux-large-jisyo* 10000)
    )
  "*List of sexps such that each element, when evaluated, returns a vector
of henkan candidates for j-henkan-key.")

(defvar *skk-jisyo* "~/.skk-jisyo"
  "*The name of the skk jisyo file.")

(defvar *skk-backup-jisyo* "~/.skk-jisyo.BAK"
  "*The name of the skk backup jisyo file.")

(defvar *skk-jisyo-code* nil
  "*If non-nil, it is used as the value of kanji-fileio-code for the jisyo
buffer.")

(defvar *skk-record-file* "~/.skk-record"
  "*The name of the skk record file.")

(defvar *skk-kakutei-key* #\C-j
  "*Key sequence that will invoke the command j-kakutei.")

(defvar *skk-date-ad* nil
  "*If non-nil, j-date is in A.D.  If nil, it is in Nengo (Heisei).")

(defvar *skk-number-style* 1
  "*If nil or 0, numbers in j-date are in Hankaku. If t or 1, in Zenkaku.
Otherwise Kanji.")

(defvar *skk-keep-record* t
  "*If t, skk will keep record of the success rate of kana to kanji conversion
etc. in the file ~/.skk-record.")

(defvar *skk-auto-okuri-process* nil
  "*If t, skk automatically recognizes okuri-gana part.  For instance, you
can just type `Uresii ' and it will be converted as you expect. This
behavior is available only if *skk-process-okuri-early* is nil.")

(defvar *skk-process-okuri-early* nil
  "*If t, skk will start kana to kanji conversion when it reads the first
roman character for okurigana, if nil then kana to kanji conversion will
start only when it reads a complete roman representation for a kana
character.")

(defvar *skk-egg-like-newline* nil
  "*If non-nil, no newline is inserted in any henkan mode.")

(defvar *skk-kakutei-early* t
  "*If t, the values of J-HENKAN-ACTIVE is also t, and *skk-process-okuri-early*
is nil, then skk will kakutei the current candidate when j-kana-input is
called.")

(defvar *j-henkan-show-candidates-keys* '(#\a #\s #\d #\f #\j #\k #\l)
  "*Chars when you select candidates by menu. This list should contain 7
characters.")

(defvar *skk-mode-string* "--SKK:"
  "*The value of this constant is used in the mode line when skk is in ascii
mode.")

(defvar *skk-hirakana-mode-string* "--Ç©Ç»"
  "*The value of this constant is used in the mode line when skk is in hirakana
mode.")

(defvar *skk-katakana-mode-string* "--ÉJÉi"
  "*The value of this constant is used in the mode line when skk is in katakana
mode.")

(defvar *skk-zenei-mode-string* "--ëSâp"
  "*The value of this constant is used in the mode line when skk is in zenei
mode.")

(defvar *skk-echo* t
  "*If T, echoes prefix for kana characters.")

(defvar *skk-server-host* (si:getenv "SKKSERVER")
  "*Name of the host running SKK Jisyo Server")

(defvar *skk-serv* (si:getenv "SKKSERV")
  "*Name of the SKK Jisyo Server program")

(defvar *skk-server-list* nil
  "*List of the SKK Jisyo Server")

(defvar *skk-portnum* nil
  "*If the value is non-nil, it must be the PORTNUM defined in skkserv.h")

(defvar *skk-report-server-response* nil
  "*When SKK sends a request to SKK SERVER, SKK waits for the process output
by repeatedly executing the accept-process-output function.  If this constant
is t, then SKK will report the number of times the function is called.")

(defvar *skk-use-numeric-conversion* t
  "*If t, convert numerals in the henkan word appropriately.")

(defvar *skk-mule* (and (boundp 'MULE) MULE)
  "If t, it means that skk is running under Mule.")

(defvar *skk-dabbrev-like-completion* nil
  "*If t, completion will be done like dabbrev-expand.  namely, if one tries
completion successively, completion will be done for the initial completion
word rather than the most recently completed word.")

(defvar *skk-delete-implies-kakutei* t
  "*This variable is use to control the behavior of the function
j-delete-backward-char when it is called with j-henkan-active being t.
If the variable is non-nil, the previous charater will be deleted and
j-kakutei will be called.  If nil, j-previous-candidate will be called
instead.")

(defvar *skk-delete-okuri-when-quit* nil)

(defvar *skk-num-type-list*
  '((#\0 . identity)
    (#\1 . j-zenkaku-num-str)
    (#\2 . j-kanji-num-str)
    (#\3 . j-kanji-num-str2)
    (#\9 . j-shogi-num-str))
  "*association list of type-function pairs used in the conversion of numeric
arguments in henkan key.")

(defvar *skk-char-type-vector*
  #(0 0 0 0 0 0 0 0
    5 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 4 4 4 4 4 4 4
    4 4 4 4 0 4 4 4
    4 0 4 4 4 4 4 4
    0 4 4 0 0 0 0 0
    0 3 1 1 1 3 1 1
    1 3 1 1 0 1 2 3
    1 0 1 1 1 3 1 1
    2 1 1 0 0 0 0 5)
  "*char type is interpreted as follows.
0 exit rom-kana conversion (not used at present)
1 consonant that can be part of sokuon
2 other consonants (n, x)
3 vowel
4 bound to j-set-henkan-point in skk-mode
5 delete prefix")

(defvar *skk-kana-rom-vector*
  #("x" "a" "x" "i" "x" "u" "x" "e" "x" "o" "k" "g" "k" "g" "k" "g"
    "k" "g" "k" "g" "s" "z" "s" "j" "s" "z" "s" "z" "s" "z" "t" "d"
    "t" "d" "x" "t" "d" "t" "d" "t" "d" "n" "n" "n" "n" "n" "h" "b"
    "p" "h" "b" "p" "h" "b" "p" "h" "b" "p" "h" "b" "p" "m" "m" "m"
    "m" "m" "x" "y" "x" "y" "x" "y" "r" "r" "r" "r" "r" "x" "w" "x"
    "x" "w" "n")
  "*kana to roman conversion giving only the first roman character
corresponding to the following kana characters.  For the characters
ÅuÇ∂Åv, ÅuÇøÅv,ÅuÇ”Åv, you might want to change the values for them to
\"z\", \"c\", \"f\".
Çü  Ç†  Ç°  Ç¢  Ç£  Ç§  Ç•  Ç¶  Çß  Ç®  Ç©  Ç™  Ç´  Ç¨  Ç≠  ÇÆ
ÇØ  Ç∞  Ç±  Ç≤  Ç≥  Ç¥  Çµ  Ç∂  Ç∑  Ç∏  Çπ  Ç∫  Çª  Çº  ÇΩ  Çæ
Çø  Ç¿  Ç¡  Ç¬  Ç√  Çƒ  Ç≈  Ç∆  Ç«  Ç»  Ç…  Ç   ÇÀ  ÇÃ  ÇÕ  ÇŒ
Çœ  Ç–  Ç—  Ç“  Ç”  Ç‘  Ç’  Ç÷  Ç◊  Çÿ  ÇŸ  Ç⁄  Ç€  Ç‹  Ç›  Çﬁ
Çﬂ  Ç‡  Ç·  Ç‚  Ç„  Ç‰  ÇÂ  ÇÊ  ÇÁ  ÇË  ÇÈ  ÇÍ  ÇÎ  ÇÏ  ÇÌ  ÇÓ
ÇÔ  Ç  ÇÒ")

(defvar *skk-prefix-list*
  '("by" "ch" "cy" "dh" "dy" "fy" "gy" "hy" "jy" "ky" "my" "py" "ry" "sh" "sy"
    "th" "ts" "ty" "xk" "xt" "xts" "xw" "xy" "zy"))

(defvar *skk-rom-kana-rule-list*
  '(("nn" nil ("Éì" . "ÇÒ"))
    ("n'" nil ("Éì" . "ÇÒ"))))

(defvar *skk-rom-kana-rule-tree* nil)

(defvar *skk-roma-kana-a*
  '(("" . ("Ç†" . "ÉA"))
    ("b" . ("ÇŒ" . "Éo")) ("by" . ("Ç—Ç·" . "ÉrÉÉ"))
    ("ch" . ("ÇøÇ·" . "É`ÉÉ")) ("cy" . ("ÇøÇ·" . "É`ÉÉ"))
    ("d" . ("Çæ" . "É_")) ("dh" . ("Ç≈Ç·" . "ÉfÉÉ"))
    ("dy" . ("Ç¿Ç·" . "ÉaÉÉ"))
    ("f" . ("Ç”Çü" . "ÉtÉ@")) ("fy" . ("Ç”Ç·" . "ÉtÉÉ"))
    ("g" . ("Ç™" . "ÉK")) ("gy" . ("Ç¨Ç·" . "ÉMÉÉ"))
    ("h" . ("ÇÕ" . "Én")) ("hy" . ("Ç–Ç·" . "ÉqÉÉ"))
    ("j" . ("Ç∂Ç·" . "ÉWÉÉ")) ("jy" . ("Ç∂Ç·" . "ÉWÉÉ"))
    ("k" . ("Ç©" . "ÉJ")) ("ky" . ("Ç´Ç·" . "ÉLÉÉ"))
    ("m" . ("Ç‹" . "É}")) ("my" . ("Ç›Ç·" . "É~ÉÉ"))
    ("n" . ("Ç»" . "Éi")) ("ny" . ("Ç…Ç·" . "ÉjÉÉ"))
    ("p" . ("Çœ" . "Ép")) ("py" . ("Ç“Ç·" . "ÉsÉÉ"))
    ("r" . ("ÇÁ" . "Éâ")) ("ry" . ("ÇËÇ·" . "ÉäÉÉ"))
    ("s" . ("Ç≥" . "ÉT")) ("sh" . ("ÇµÇ·" . "ÉVÉÉ"))
    ("sy" . ("ÇµÇ·" . "ÉVÉÉ"))
    ("t" . ("ÇΩ" . "É^")) ("th" . ("ÇƒÇü" . "ÉeÉ@"))
    ("ty" . ("ÇøÇ·" . "É`ÉÉ"))
    ("v" . ("Ç§ÅJÇü" . "ÉîÉ@")) ("w" . ("ÇÌ" . "Éè"))
    ("x" . ("Çü" . "É@")) ("xk" . ("Ç©" . "Éï"))
    ("xw" . ("ÇÏ" . "Éé")) ("xy" . ("Ç·" . "ÉÉ"))
    ("y" . ("Ç‚" . "ÉÑ"))
    ("z" . ("Ç¥" . "ÉU")) ("zy" . ("Ç∂Ç·" . "ÉWÉÉ"))))

(defvar *skk-roma-kana-i*
  '(("" . ("Ç¢" . "ÉC"))
    ("b" . ("Ç—" . "Ér")) ("by" . ("Ç—Ç°" . "ÉrÉB"))
    ("ch" . ("Çø" . "É`")) ("cy" . ("ÇøÇ°" . "É`ÉB"))
    ("d" . ("Ç¿" . "Éa")) ("dh" . ("Ç≈Ç°" . "ÉfÉB"))
    ("dy" . ("Ç¿Ç°" . "ÉaÉB"))
    ("f" . ("Ç”Ç°" . "ÉtÉB")) ("fy" . ("Ç”Ç°" . "ÉtÉB"))
    ("g" . ("Ç¨" . "ÉM")) ("gy" . ("Ç¨Ç°" . "ÉMÉB"))
    ("h" . ("Ç–" . "Éq")) ("hy" . ("Ç–Ç°" . "ÉqÉB"))
    ("j" . ("Ç∂" . "ÉW")) ("jy" . ("Ç∂Ç°" . "ÉWÉB"))
    ("k" . ("Ç´" . "ÉL")) ("ky" . ("Ç´Ç°" . "ÉLÉB"))
    ("m" . ("Ç›" . "É~")) ("my" . ("Ç›Ç°" . "É~ÉB"))
    ("n" . ("Ç…" . "Éj")) ("ny" . ("Ç…Ç°" . "ÉjÉB"))
    ("p" . ("Ç“" . "És")) ("py" . ("Ç“Ç°" . "ÉsÉB"))
    ("r" . ("ÇË" . "Éä")) ("ry" . ("ÇËÇ°" . "ÉäÉB"))
    ("s" . ("Çµ" . "ÉV")) ("sh" . ("Çµ" . "ÉV"))
    ("sy" . ("ÇµÇ°" . "ÉVÉB"))
    ("t" . ("Çø" . "É`")) ("th" . ("ÇƒÇ°" . "ÉeÉB"))
    ("ty" . ("ÇøÇ°" . "É`ÉB"))
    ("v" . ("Ç§ÅJÇ°" . "ÉîÉB")) ("w" . ("Ç§Ç°" . "ÉEÉB"))
    ("x" . ("Ç°" . "ÉB")) ("xw" . ("ÇÓ" . "Éê"))
    ("z" . ("Ç∂" . "ÉW")) ("zy" . ("Ç∂Ç°" . "ÉWÉB"))))

(defvar *skk-roma-kana-u*
  '(("" . ("Ç§" . "ÉE"))
    ("b" . ("Ç‘" . "Éu")) ("by" . ("Ç—Ç„" . "ÉrÉÖ"))
    ("ch" . ("ÇøÇ„" . "É`ÉÖ")) ("cy" . ("ÇøÇ„" . "É`ÉÖ"))
    ("d" . ("Ç√" . "Éd")) ("dh" . ("Ç≈Ç„" . "ÉfÉÖ"))
    ("dy" . ("Ç¿Ç„" . "ÉaÉÖ"))
    ("f" . ("Ç”" . "Ét")) ("fy" . ("Ç”Ç„" . "ÉtÉÖ"))
    ("g" . ("ÇÆ" . "ÉO")) ("gy" . ("Ç¨Ç„" . "ÉMÉÖ"))
    ("h" . ("Ç”" . "Ét")) ("hy" . ("Ç–Ç„" . "ÉqÉÖ"))
    ("j" . ("Ç∂Ç„" . "ÉWÉÖ")) ("jy" . ("Ç∂Ç„" . "ÉWÉÖ"))
    ("k" . ("Ç≠" . "ÉN")) ("ky" . ("Ç´Ç„" . "ÉLÉÖ"))
    ("m" . ("Çﬁ" . "ÉÄ")) ("my" . ("Ç›Ç„" . "É~ÉÖ"))
    ("n" . ("Ç " . "Ék")) ("ny" . ("Ç…Ç„" . "ÉjÉÖ"))
    ("p" . ("Ç’" . "Év")) ("py" . ("Ç“Ç„" . "ÉsÉÖ"))
    ("r" . ("ÇÈ" . "Éã")) ("ry" . ("ÇËÇ„" . "ÉäÉÖ"))
    ("s" . ("Ç∑" . "ÉX")) ("sh" . ("ÇµÇ„" . "ÉVÉÖ"))
    ("sy" . ("ÇµÇ„" . "ÉVÉÖ"))
    ("t" . ("Ç¬" . "Éc")) ("th" . ("ÇƒÇ„" . "ÉeÉÖ"))
    ("ts" . ("Ç¬" . "Éc")) ("ty" . ("ÇøÇ„" . "É`ÉÖ"))
    ("v" . ("Ç§ÅJ" . "Éî")) ("w" . ("Ç§" . "ÉE"))
    ("x" . ("Ç£" . "ÉD")) ("xt" . ("Ç¡" . "Éb"))
    ("xts" . ("Ç¡" . "Éb")) ("xy" . ("Ç„" . "ÉÖ"))
    ("y" . ("Ç‰" . "ÉÜ"))
    ("z" . ("Ç∏" . "ÉY")) ("zy" . ("Ç∂Ç„" . "ÉWÉÖ"))))

(defvar *skk-roma-kana-e*
  '(("" . ("Ç¶" . "ÉG"))
    ("b" . ("Ç◊" . "Éx")) ("by" . ("Ç—Ç•" . "ÉrÉF"))
    ("ch" . ("ÇøÇ•" . "É`ÉF")) ("cy" . ("ÇøÇ•" . "É`ÉF"))
    ("d" . ("Ç≈" . "Éf")) ("dh" . ("Ç≈Ç•" . "ÉfÉF"))
    ("dy" . ("Ç¿Ç•" . "ÉaÉF"))
    ("f" . ("Ç”Ç•" . "ÉtÉF")) ("fy" . ("Ç”Ç•" . "ÉtÉF"))
    ("g" . ("Ç∞" . "ÉQ")) ("gy" . ("Ç¨Ç•" . "ÉMÉF"))
    ("h" . ("Ç÷" . "Éw")) ("hy" . ("Ç–Ç•" . "ÉqÉF"))
    ("j" . ("Ç∂Ç•" . "ÉWÉF")) ("jy" . ("Ç∂Ç•" . "ÉWÉF"))
    ("k" . ("ÇØ" . "ÉP")) ("ky" . ("Ç´Ç•" . "ÉLÉF"))
    ("m" . ("Çﬂ" . "ÉÅ")) ("my" . ("Ç›Ç•" . "É~ÉF"))
    ("n" . ("ÇÀ" . "Él")) ("ny" . ("Ç…Ç•" . "ÉjÉF"))
    ("p" . ("Çÿ" . "Éy")) ("py" . ("Ç“Ç•" . "ÉsÉF"))
    ("r" . ("ÇÍ" . "Éå")) ("ry" . ("ÇËÇ•" . "ÉäÉF"))
    ("s" . ("Çπ" . "ÉZ")) ("sh" . ("ÇµÇ•" . "ÉVÉF"))
    ("sy" . ("ÇµÇ•" . "ÉVÉF"))
    ("t" . ("Çƒ" . "Ée")) ("th" . ("ÇƒÇ•" . "ÉeÉF"))
    ("ty" . ("ÇøÇ•" . "É`ÉF"))
    ("v" . ("Ç§ÅJÇ•" . "ÉîÉF")) ("w" . ("Ç§Ç•" . "ÉEÉF"))
    ("x" . ("Ç•" . "ÉF")) ("xk" . ("ÇØ" . "Éñ"))
    ("xw" . ("ÇÔ" . "Éë"))
    ("y" . ("Ç¢Ç•" . "ÉCÉF"))
    ("z" . ("Ç∫" . "É[")) ("zy" . ("Ç∂Ç•" . "ÉWÉF"))))

(defvar *skk-roma-kana-o*
  '(("" . ("Ç®" . "ÉI"))
    ("b" . ("Ç⁄" . "É{")) ("by" . ("Ç—ÇÂ" . "ÉrÉá"))
    ("ch" . ("ÇøÇÂ" . "É`Éá")) ("cy" . ("ÇøÇÂ" . "É`Éá"))
    ("d" . ("Ç«" . "Éh")) ("dh" . ("Ç≈ÇÂ" . "ÉfÉá"))
    ("dy" . ("Ç¿ÇÂ" . "ÉaÉá"))
    ("f" . ("Ç”Çß" . "ÉtÉH")) ("fy" . ("Ç”ÇÂ" . "ÉtÉá"))
    ("g" . ("Ç≤" . "ÉS")) ("gy" . ("Ç¨ÇÂ" . "ÉMÉá"))
    ("h" . ("ÇŸ" . "Éz")) ("hy" . ("Ç–ÇÂ" . "ÉqÉá"))
    ("j" . ("Ç∂ÇÂ" . "ÉWÉá")) ("jy" . ("Ç∂ÇÂ" . "ÉWÉá"))
    ("k" . ("Ç±" . "ÉR")) ("ky" . ("Ç´ÇÂ" . "ÉLÉá"))
    ("m" . ("Ç‡" . "ÉÇ")) ("my" . ("Ç›ÇÂ" . "É~Éá"))
    ("n" . ("ÇÃ" . "Ém")) ("ny" . ("Ç…ÇÂ" . "ÉjÉá"))
    ("p" . ("Ç€" . "É|")) ("py" . ("Ç“ÇÂ" . "ÉsÉá"))
    ("r" . ("ÇÎ" . "Éç")) ("ry" . ("ÇËÇÂ" . "ÉäÉá"))
    ("s" . ("Çª" . "É\")) ("sh" . ("ÇµÇÂ" . "ÉVÉá"))
    ("sy" . ("ÇµÇÂ" . "ÉVÉá"))
    ("t" . ("Ç∆" . "Ég")) ("th" . ("ÇƒÇÂ" . "ÉeÉá"))
    ("ty" . ("ÇøÇÂ" . "É`Éá"))
    ("v" . ("Ç§ÅJÇß" . "ÉîÉH")) ("w" . ("Ç" . "Éí"))
    ("x" . ("Çß" . "ÉH")) ("xy" . ("ÇÂ" . "Éá"))
    ("y" . ("ÇÊ" . "Éà"))
    ("z" . ("Çº" . "É]")) ("zy" . ("Ç∂ÇÂ" . "ÉWÉá"))))

(defvar *skk-input-vector*
  #(nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  "ÅI" nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  "ÅA" "Å[" "ÅB" nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  "ÅF" "ÅG" nil  nil  nil  "ÅH"
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  "Åu" nil  "Åv" nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil)
  "*Translation table for j-self inserting characters.")

(defvar *skk-zenkaku-vector*
  #(nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    nil  nil  nil  nil  nil  nil  nil  nil
    "Å@"  "ÅI" "Åh" "Åî" "Åê" "Åì" "Åï" "Åf"
    "Åi" "Åj" "Åñ" "Å{" "ÅC" "Å|" "ÅD" "Å^"
    "ÇO" "ÇP" "ÇQ" "ÇR" "ÇS" "ÇT" "ÇU" "ÇV"
    "ÇW" "ÇX" "ÅF" "ÅG" "ÅÉ" "ÅÅ" "ÅÑ" "ÅH"
    "Åó" "Ç`" "Ça" "Çb" "Çc" "Çd" "Çe" "Çf"
    "Çg" "Çh" "Çi" "Çj" "Çk" "Çl" "Çm" "Çn"
    "Ço" "Çp" "Çq" "Çr" "Çs" "Çt" "Çu" "Çv"
    "Çw" "Çx" "Çy" "Åm" "Å_" "Ån" "ÅO" "ÅQ"
    "Åe" "ÇÅ" "ÇÇ" "ÇÉ" "ÇÑ" "ÇÖ" "ÇÜ" "Çá"
    "Çà" "Çâ" "Çä" "Çã" "Çå" "Çç" "Çé" "Çè"
    "Çê" "Çë" "Çí" "Çì" "Çî" "Çï" "Çñ" "Çó"
    "Çò" "Çô" "Çö" "Åo" "Åb" "Åp" "Å`" nil))

(defvar *skk-auto-fill-mode-hook* nil)

(defvar *skk-dserver-connection* nil)


;; utilities

(defun skk-file-name-nondirectory (fn)
  (let ((name (pathname-name fn))
        (type (pathname-type fn)))
    (if type
        (format nil "~A.~A" name type)
      name)))

(defun skk-search-forward (str &optional limit noerror)
  (let ((result (scan-buffer str :limit limit :tail t)))
    (if result
        (point)
      (if (not noerror)
          (error "search failed")
        (progn
          (unless (eq noerror t)
            (goto-char (or limit (point-max))))
          nil)))))

(defun skk-copy-marker (marker)
  (let ((new-marker (make-marker (and (markerp marker)
                                      (marker-buffer marker)))))
    (with-set-buffer
      (save-excursion
        (set-buffer (marker-buffer new-marker))
        (set-marker new-marker marker)))
    new-marker))

(defmacro skk-set-marker (marker pos)
  `(let ((pos ,pos))
     (if (markerp pos)
         (setq ,marker (skk-copy-marker pos))
       (progn
         (setq ,marker (make-marker))
         (set-marker ,marker pos)))))

(defun skk-delete-region (begin end)
  (if (or (markerp begin) (markerp end))
      (with-set-buffer
        (save-excursion
          (let ((buf (if (markerp begin) (marker-buffer begin) (marker-buffer end))))
            (unless (eq buf (selected-buffer))
              (set-buffer buf))
            (delete-region begin end))))
    (delete-region begin end)))

(defun skk-make-string (count char)
  (make-vector count :initial-element char :element-type 'character))

(defun skk-char-jis-code (char)
  (if (kanji-char-p char)
      (let* ((jstr (map-internal-to-jis (string char)))
             (b1 (char-code (aref jstr 3)))
             (b2 (char-code (aref jstr 4))))
        (+ (* b1 256) b2))
    (char-code char)))

(defun skk-jis-code-char (code)
  (if (> code 256)
      (schar (map-jis-to-internal (format nil "\x1b$B~C\x1b(J" (code-char code))) 0)
    (code-char code)))

(defun skk-mapconcat (func seq sep)
  (labels ((join (lst sep)
             (if (<= (length lst) 1)
                 lst
               (cons (car lst)
                     (cons sep
                           (join (cdr lst) sep))))))
    (apply #'concatenate (cons 'string (join (mapcar func (concatenate 'list seq)) sep)))))

(defun skk-delete-selection ()
  (when (pre-selection-p)
    (delete-region (selection-mark) (selection-point))
    (stop-selection)))

(defun skk-joinstr (glue lst)
  (reduce (lambda (x y) (concat x glue y)) lst))

(defun skk-erase-popup ()
 (let ((wnd (get-window-handle (selected-window))))
   (winapi::SendMessage wnd #xA0 0 0)
   (winapi::SendMessage wnd #xA0 0 0)))

;;;

(defun j-change-mode-line (str)
  (setq mode-line-format (format nil "~A~A" str j-mode-line-format))
  (update-mode-line))

(defun j-today ()
  "Insert current date at point in Kanji."
  (interactive)
  (skk-delete-selection)
  (insert (j-date)))

(defun j-date (&optional date-ad number-style)
  (let* ((*skk-date-ad* (or date-ad *skk-date-ad*))
         (*skk-number-style* (or number-style *skk-number-style*))
         (str (format-date-string "%a %b %d %H:%M:%S %Y"))
         (y (- (parse-integer (substring str 20 24)) 1988))
         (year (if *skk-date-ad*
                   (j-num (substring str 20 24))
                 (if (= y 1) "å≥" (j-num (format nil "~D" y)))))
         (mon (substring str 4 7))
         (month (j-num (cdr (assoc mon
                                   '(("Jan" . "1") ("Feb" . "2") ("Mar" . "3")
                                     ("Apr" . "4") ("May" . "5") ("Jun" . "6")
                                     ("Jul" . "7") ("Aug" . "8") ("Sep" . "9")
                                     ("Oct" . "10") ("Nov" . "11") ("Dec" . "12"))
                                   :test #'string=))))
         (day (j-num (substring str 8 10)))
         (dw (substring str 0 3))
         (day-of-week (cdr (assoc dw
                                  '(("Sun" . "ì˙") ("Mon" . "åé") ("Tue" . "âŒ")
                                    ("Wed" . "êÖ") ("Thu" . "ñÿ") ("Fri" . "ã‡")
                                    ("Sat" . "ìy"))
                                  :test #'string=))))
    (format nil "~A~AîN~Aåé~Aì˙(~A)" (if *skk-date-ad* "" "ïΩê¨") year month day day-of-week)))

(defun j-num (str)
  "convert a number string to other style according to SKK-NUMBER-STYLE"
  (skk-mapconcat (function j-num1) str ""))

(defun j-num1 (c)
  "convert a number character to other style according to SKK-NUMBER-STYLE"
  (cond ((or (null *skk-number-style*) (eq *skk-number-style* 0))
         (cdr (assoc c
                     '((#\0 . "0") (#\1 . "1") (#\2 . "2") (#\3 . "3")
                       (#\4 . "4") (#\5 . "5") (#\6 . "6") (#\7 . "7")
                       (#\8 . "8") (#\9 . "9") (#\SPC  . ""))
                     :test #'eq)))
        ((or (eq *skk-number-style* t) (eq *skk-number-style* 1))
         (cdr (assoc c
                     '((#\0 . "ÇO") (#\1 . "ÇP") (#\2 . "ÇQ") (#\3 . "ÇR")
                       (#\4 . "ÇS") (#\5 . "ÇT") (#\6 . "ÇU") (#\7 . "ÇV")
                       (#\8 . "ÇW") (#\9 . "ÇX") (#\SPC  . ""))
                     :test #'eq)))
        (t
         (cdr (assoc c
                     '((#\0 . "ÅZ") (#\1 . "àÍ") (#\2 . "ìÒ") (#\3 . "éO")
                       (#\4 . "él") (#\5 . "å‹") (#\6 . "òZ") (#\7 . "éµ")
                       (#\8 . "î™") (#\9 . "ã„") (#\SPC  . ""))
                     :test #'eq)))))

(defun j-convert-to-vector (map)
  "convert a map in list form to a map in vector form."
  (if (vectorp map)
      (copy-keymap map)
    (let ((new-map (make-keymap))
          (l (cdr map))
          def)
      (while l
        (setq def (cdar l))
        (setf (aref new-map (*keymap-char-index (caar l))) (if (keymapp def)
                                                               (copy-keymap def)
                                                             def))
        (setq l (cdr l)))
      new-map)))

(defun j-in-minibuffer ()
  "check if the minibuffer is currently selected."
  (eq (selected-window) (minibuffer-window)))

(defun j-do-auto-fill ()
  (when (and auto-fill ed::*auto-fill-hook)
    (funcall ed::*auto-fill-hook #\SPC)) ;; #\SPC is dummy. Depends on the initial settings of auto-fill-mode.
  )

(defun skk-auto-fill-mode (&optional (arg nil sarg))
  (interactive "p")
  (if (null sarg)
      (auto-fill-mode)
    (auto-fill-mode arg))
  (unless skk-mode
    (skk-mode 1))
  (run-hooks '*skk-auto-fill-mode-hook*))

;; kana inserting functions

(defun j-insert (table)
  (let ((char (assoc *j-prefix* table :test #'equal)))
    (if (null char)
        ;; *j-prefix* not found in the table
        (progn
          (setq *j-prefix* "")
          (unread-char *last-command-char* *keyboard*))
      (progn
        (when (and *j-kakutei-early* j-henkan-active)
          (j-kakutei))
        (j-insert-str (if j-katakana (cddr char) (cadr char)))
        (if j-okurigana
            (j-set-okurigana)
          (setq *j-prefix* ""))
        (if (not j-henkan-on) (j-do-auto-fill))))))

(defun j-ovwrt-len (len)
  (min (length
        (buffer-substring (point) (save-excursion (goto-eol) (point))))
       len))

(defun j-insert-str (str)
  "Insert STR and, if necessary, take care of overwrite-mode"
  (skk-delete-selection)
  (insert str)
  (refresh-screen)
  (unless j-henkan-on
    (when overwrite-mode
      (j-del-char-with-pad (j-ovwrt-len (length str))))))

(defun j-del-char-with-pad (length)
  "Delete exactly LENGTH width, by inserting a space at the end,
if necessary, for adjustment."
  (let ((p (point))
        (len 0))
    (while (< len length)
      (forward-char 1)
      (setq len (length (buffer-substring (point) p))))
    (delete-region p (point))
    (unless (= length len)
      (insert #\SPC)
      (backward-char 1))))

(defun j-set-okurigana ()
  (let (w-head)
    (skk-set-marker j-henkan-end-point j-okurigana-start-point)
    (save-excursion
      ;; just in case
      (goto-char j-okurigana-start-point)
      (or (looking-at "*") (insert #\*)))
    (setq w-head (buffer-substring j-henkan-start-point j-henkan-end-point))
    (setq j-henkan-key2
          (format nil "~A*~A" w-head (setq j-henkan-okurigana
                                           (buffer-substring
                                            (1+ (marker-point j-okurigana-start-point))
                                            (point)))))
    (setq j-henkan-key (format nil "~A~A" w-head j-okuri-char))
    (setq *j-prefix* ""
          j-okuri-char "")
    (skk-delete-region j-okurigana-start-point (1+ (marker-point j-okurigana-start-point)))
    (j-henkan)
    (refresh-screen)
    (setq j-okurigana nil)))

(defun j-insert-a ()
  (interactive)
  (j-insert *skk-roma-kana-a*))

(defun j-insert-i ()
  (interactive)
  (j-insert *skk-roma-kana-i*))

(defun j-insert-u ()
  (interactive)
  (j-insert *skk-roma-kana-u*))

(defun j-insert-e ()
  (interactive)
  (j-insert *skk-roma-kana-e*))

(defun j-insert-o ()
  (j-insert *skk-roma-kana-o*))

(defun j-erase-prefix ()
  "erase *j-prefix* characters if *skk-echo* is on."
  (if *skk-echo*
      (skk-delete-region j-kana-start-point (point))))

(defun j-insert-prefix (&optional char)
  "insert *j-prefix* if *skk-echo* is on"
  (skk-delete-selection)
  (when *skk-echo*
    (insert (or char *j-prefix*))
    (refresh-screen)))

;; other inserting functions

(defun j-insert-comma (&optional (count 1))
  (interactive "p")
  (if (eq *last-command* 'j-completion)
      (j-previous-completion)
    (j-self-insert count)))

(defun j-insert-period (&optional (count 1))
  (interactive "p")
  (if (eq *last-command* 'j-completion)
      (progn
        (setq *this-command* 'j-completion)
        (j-completion nil))
    (j-self-insert count)))

;; kana input by romaji to kana conversion

(defun j-kana-input ()
  "Start romaji-to-kana conversion.  The character `o' calls this function in
order to treat `ohta' etc."
  (interactive)
  (when (and *j-kakutei-early* j-henkan-active)
    (j-kakutei))
  (let ((char (string *last-command-char*))
        (cont t))
    (when *skk-isearch-message*
      (j-isearch-message))
    (if (and (char= *last-command-char* #\o)
             (null (j-assoc-rule (format nil "~A~A" *j-prefix* char))))
        (progn
          (j-insert-o)
          (if *skk-isearch-message*
              (progn
                (j-isearch-message)
                (setq cont nil)
                ;; thus you must type `oota' instead of `ohta' when inputting
                ;; isearch string
                )
            (progn
              (setq *j-prefix* char)
              (skk-set-marker j-kana-start-point (point)))))
      (progn
        (setq *j-prefix* char)
        (skk-set-marker j-kana-start-point (point))
        (j-insert-prefix)))
    (handler-case
        (while cont
          (let* ((r-char (read-char *keyboard*))
                 (r-char (if (char= r-char #\C-g)
                             (quit)
                           (if (and j-henkan-on
                                    (not j-henkan-active)
                                    ;; we must distinguish the two cases where
                                    ;; *skk-echo* is on and off
                                    (= (marker-point j-henkan-start-point)
                                       (if *skk-echo* (1- (point)) (point)))
                                    (upper-case-p r-char)
                                    (string/= *j-prefix* "o"))
                               ;; this case takes care of the rare case where
                               ;; one types two characters in upper case
                               ;; consequtively.  For example, one sometimes
                               ;; types "TE" when one should type "Te"
                               (char-downcase r-char)
                             r-char)))
                 (input (string r-char))
                 (prefix (format nil "~A~A" *j-prefix* input))
                 (next (j-assoc-rule prefix)))
            (if *skk-isearch-message* (j-isearch-message))
            (cond (next
                   (let ((newprefix (car next))
                         (output (cadr next)))
                     (j-erase-prefix)
                     (if output
                         (progn
                           (j-insert-str
                            (if j-katakana (car output) (cdr output)))
                           (if j-okurigana (j-set-okurigana))))
                     (if newprefix
                         (progn
                           (skk-set-marker j-kana-start-point (point))
                           (j-insert-prefix newprefix)
                           (setq *j-prefix* newprefix))
                       (setq cont nil
                             *j-prefix* ""))))
                  ((string= *j-prefix* "n")
                   (cond ((= (aref *skk-char-type-vector* (char-code r-char)) 3) ;; vowel
                          (j-erase-prefix)
                          (setq cont nil)
                          (unread-char r-char *keyboard*))
                         ((char= r-char #\y)
                          (setq *j-prefix* prefix)
                          (j-insert-prefix #\y))
                         ((and j-okurigana (char= r-char #\SPC))
                          (unread-char #\n *keyboard*))
                         (t
                          (j-erase-prefix)
                          (j-insert-str (if j-katakana "Éì" "ÇÒ"))
                          (skk-set-marker j-kana-start-point (point))
                          (setq *j-prefix* "")
                          (setq cont nil)
                          (unread-char r-char *keyboard*))))
                  ((string= *j-prefix* "o")
                   (if (char= r-char #\h)
                       (progn
                         (setq *j-prefix* prefix)
                         (j-insert-prefix #\h))
                     (progn
                       (j-erase-prefix)
                       (setq cont nil
                             *j-prefix* "")
                       (unread-char r-char *keyboard*))))
                  ((string= *j-prefix* "oh")
                   (if (= (aref *skk-char-type-vector* (char-code r-char)) 3)
                       ;; vowel
                       (progn
                         (setq cont nil)
                         (j-erase-prefix)
                         (setq *j-prefix* "h")
                         (unread-char r-char *keyboard*))
                     (progn
                       (j-erase-prefix)
                       (j-insert-str (if j-katakana "ÉI" "Ç®"))
                       (setq cont nil
                             *j-prefix* "")
                       (unread-char r-char *keyboard*))))
                  ((and (string= input *j-prefix*)
                        (= (aref *skk-char-type-vector* (char-code r-char)) 1))
                   (j-erase-prefix)
                   (j-insert-str (if j-katakana "Éb" "Ç¡"))
                   (skk-set-marker j-kana-start-point (point))
                   (j-insert-prefix r-char))
                  ((member prefix *skk-prefix-list* :test #'string=)
                   (setq *j-prefix* prefix)
                   (j-insert-prefix input))
                  ((= (aref *skk-char-type-vector* (char-code r-char)) 3) ;; vowel
                   (setq cont nil)
                   (j-erase-prefix)
                   (unread-char r-char *keyboard*))
                  ((= (aref *skk-char-type-vector* (char-code r-char)) 4)
                   ;; j-set-henkan-point
                   (let ((*last-command-char* r-char))
                     (j-erase-prefix)
                     (j-set-henkan-point r-char)))
                  ((= (aref *skk-char-type-vector* (char-code r-char)) 5) ;; delete prefix
                   (setq cont nil)
                   (when (and j-okurigana
                              (char= (char-after j-okurigana-start-point) #\*))
                     (skk-delete-region j-okurigana-start-point
                                        (1+ (marker-point j-okurigana-start-point)))
                     (skk-set-marker j-kana-start-point j-okurigana-start-point)
                     (setq j-okurigana nil))
                   (unless (string= *j-prefix* "")
                     (if *skk-echo*
                         (j-erase-prefix)
                       (message "Deleted prefix \"~A\"." *j-prefix*)))
                   (setq *j-prefix* ""))
                  (t
                   (setq cont nil)
                   (j-erase-prefix)
                   (unset-marker j-kana-start-point)
                   (setq *j-prefix* "")
                   (unread-char r-char *keyboard*)))))
      (quit (c)
        (if (string= *j-prefix* "o")
            (j-keyboard-quit)
          (progn
            (setq *j-prefix* "")
            (j-erase-prefix)
            (unset-marker j-kana-start-point)
            (ding)))))))

;; convert *skk-rom-kana-rule-list* to *skk-rom-kana-rule-tree*.
;; The rule tree follows the following syntax:
;; <tree> ::= ((<char> . <tree>) . <tree>) | nil
;; <item> ::= (<char> . <tree>)

(defun j-compile-rule-list (l)
  "compile rom-kana-rule-list into a tree form."
  (let (tree rule)
    (while l
      (setq rule (car l))
      (setq l (cdr l))
      (setq tree (j-add-rule rule tree)))
    tree))

(defun j-add-rule (rule tree)
  "destructivley add RULE to TREE."
  (let* ((str (car rule))
         (char (schar str 0))
         (rest (substring str 1))
         (rule-body (cdr rule))
         (root tree))
    (declare (special root))
    (j-add-rule-main char rest rule-body tree)
    root))

(defun j-add-rule-main (char rest body tree)
  (let ((item (j-search-tree char tree))
        (cont t))
    (if item
        (if (string= rest "")
            (setcdr item (cons (cons 0 body) (cdr item)))
          (j-add-rule-main
           (schar rest 0) (substring rest 1) body (cdr item)))
      ;; key not found, so add rule to the end of the tree
      (if (null root)
          (setq root (j-make-rule-tree char rest body))
        (while (and cont tree)
          (if (null (cdr tree))
              (progn
                (setf (cdr tree) (j-make-rule-tree char rest body))
                (setq cont nil))
            (setq tree (cdr tree))))))))

(defun j-make-rule-tree (char rest body)
  (if (string= rest "")
      (list (cons char (list (cons 0 body))))
    (list
     (cons char
           (j-make-rule-tree
            (schar rest 0) (substring rest 1) body)))))

(defun j-search-tree (char tree)
  (let ((cont t)
        v)
    (while (and cont tree)
      (if (char= char (caar tree))
          (setq v (car tree)
                cont nil)
        (setq tree (cdr tree))))
    v))

(defun j-assoc-rule (key)
  (if *skk-rom-kana-rule-tree*
      (j-assoc-tree key *skk-rom-kana-rule-tree*)
    (cdr (assoc key *skk-rom-kana-rule-list* :test #'string=))))

(defun j-assoc-tree (key tree)
  (let ((char (schar key 0))
        (rest (substring key 1))
        (cont t)
        v)
    (while (and tree cont)
      (if (char= char (caar tree))
          (if (string= rest "")
              (setq v (if (zerop (caadar tree))
                          (cdadar tree))
                    cont nil)
            (setq v (j-assoc-tree rest (cdar tree))
                  cont nil))
        (setq tree (cdr tree))))
    v))

;; mode setup

(defun skk-mode (&optional arg)
  "SKK mode enables input of Japanese texts without affecting the
functionality of the original mode. With negative ARG, exits from SKK mode."
  (interactive "P")
  (setq skk-mode
        (if j-mode-line-format
            (cond ((not arg) (not skk-mode))
                  ((and (symbolp arg) (> *prefix-value* 0)) t)
                  ((and (numberp arg) (> arg 0)) t)
                  ((and (consp arg) (> (car arg) 0)) t)
                  (t nil))
          ;; if skk-mode has not been called in this buffer, always
          ;; enter skk-mode
          t))
  (if (not skk-mode)
      ;; exit skk-mode
      (progn
        (let ((skk-mode t))
          (declare (special skk-mode))
          (j-kakutei))
        (setq mode-line-format j-mode-line-format)
        (use-keymap j-current-local-map)
        (set-buffer-modified-p (buffer-modified-p)))
    ;; enter skk-mode
    (progn
      (when (not *j-skk-mode-invoked*)
        ;; enter skk-mode for the first time in this session
        (setq *j-skk-mode-invoked* t)
        (load *skk-init-file* :if-does-not-exist nil) ;no error
        (setq *j-kakutei-early*
              (and *skk-kakutei-early* (not *skk-process-okuri-early*)))
        (if *skk-keep-record*
            (j-create-file *skk-record-file* "I have created an SKK record file for you."))
        (unless (file-exist-p *skk-jisyo*)
          (j-create-file *skk-jisyo* "I have created an empty Jisyo file for you."))
        (j-get-file-buffer *skk-jisyo* t)
        (setq *j-jisyo-buffer-modified* nil))
      (when (or (not j-mode-line-format) (j-in-minibuffer))
        ;; enter skk-mode for the first time in this buffer or the buffer
        ;; is the minibuffer
        (let ((map (if (j-in-minibuffer)
                       minibuffer-local-map
                     (local-keymap))))
          ;; save current mode
          (setq j-mode-line-format mode-line-format
                j-current-local-map (and map (copy-keymap map)))
          (setq j-emacs-local-map (if map (copy-keymap map) (make-sparse-keymap)))
          (define-key j-emacs-local-map *skk-kakutei-key* 'j-kakutei)
          (j-setup-skk-map)
          (j-setup-skk-zenkaku-map)
          (j-setup-skk-abbrev-map)
          (run-hooks '*skk-mode-hook*)))
      (setq j-mode t
            j-katakana nil)
      (use-keymap skk-map)
      (define-key minibuffer-local-map
                  (default-value '*skk-kakutei-key*) 'j-kakutei)
      (define-key minibuffer-local-map #\C-m 'j-newline)
      (define-key minibuffer-local-completion-map
                  (default-value '*skk-kakutei-key*) 'j-kakutei)
      (define-key minibuffer-local-completion-map #\C-m 'j-newline)
;;       (define-key minibuffer-local-ns-map
;;                   (default-value '*skk-kakutei-key*) 'j-kakutei)
;;       (define-key minibuffer-local-ns-map #\C-m 'j-newline)
      (setq *j-save-minibuffer-local-map* minibuffer-local-map)
      (make-local-variable 'mode-line-format)
      (j-change-mode-line *skk-hirakana-mode-string*))))

(defun skk-set-jisyo-code (code)
  (and code (set-buffer-fileio-encoding code)))

(defun j-setup-skk-map ()
  (setq skk-map (j-convert-to-vector j-emacs-local-map))
  (j-define-skk-map skk-map))

(defun j-setup-skk-minibuff-map ()
  (setq *skk-minibuff-map* (j-convert-to-vector minibuffer-local-map))
  (j-define-skk-map *skk-minibuff-map* t))

(defun j-define-skk-map (map &optional minibuff)
  "Setup skk key bindings for the keymap MAP.  If the optional argument
MINIBUFF is t, the map is used in the minibuffer."
  (define-key map #\C-g 'j-keyboard-quit)
  (define-key map
              (if minibuff (default-value '*skk-kakutei-key*) *skk-kakutei-key*)
              'j-kakutei)
  (define-key map #\C-m 'j-newline)
  (define-key map #\TAB 'j-try-completion)
  (define-key map #\SPC 'j-start-henkan)
  (define-key map #\! 'j-self-insert)
  (define-key map #\" 'j-self-insert)
  (define-key map #\# 'j-self-insert)
  (define-key map #\$ 'j-display-code-for-char-at-point)
  (define-key map #\% 'j-self-insert)
  (define-key map #\& 'j-self-insert)
  (define-key map #\' 'j-self-insert)
  (define-key map #\( 'j-self-insert)
  (define-key map #\) 'j-self-insert)
  (define-key map #\* 'j-self-insert)
  (define-key map #\+ 'j-self-insert)
  (define-key map #\, 'j-insert-comma)
  (define-key map #\- 'j-self-insert)
  (define-key map #\. 'j-insert-period)
  (define-key map #\/ 'j-abbrev-input)
  (define-key map #\0 'j-self-insert)
  (define-key map #\1 'j-self-insert)
  (define-key map #\2 'j-self-insert)
  (define-key map #\3 'j-self-insert)
  (define-key map #\4 'j-self-insert)
  (define-key map #\5 'j-self-insert)
  (define-key map #\6 'j-self-insert)
  (define-key map #\7 'j-self-insert)
  (define-key map #\8 'j-self-insert)
  (define-key map #\9 'j-self-insert)
  (define-key map #\: 'j-self-insert)
  (define-key map #\; 'j-self-insert)
  (define-key map #\< 'j-set-henkan-point)
  (define-key map #\= 'j-self-insert)
  (define-key map #\> 'j-set-henkan-point)
  (define-key map #\? 'j-set-henkan-point)
  (define-key map #\@ 'j-today)
  (define-key map #\A 'j-set-henkan-point)
  (define-key map #\B 'j-set-henkan-point)
  (define-key map #\C 'j-set-henkan-point)
  (define-key map #\D 'j-set-henkan-point)
  (define-key map #\E 'j-set-henkan-point)
  (define-key map #\F 'j-set-henkan-point)
  (define-key map #\G 'j-set-henkan-point)
  (define-key map #\H 'j-set-henkan-point)
  (define-key map #\I 'j-set-henkan-point)
  (define-key map #\J 'j-set-henkan-point)
  (define-key map #\K 'j-set-henkan-point)
  (define-key map #\L 'j-zenkaku-eiji)
  (define-key map #\M 'j-set-henkan-point)
  (define-key map #\N 'j-set-henkan-point)
  (define-key map #\O 'j-set-henkan-point)
  (define-key map #\P 'j-set-henkan-point)
  (define-key map #\Q 'j-set-henkan-point-subr)
  (define-key map #\R 'j-set-henkan-point)
  (define-key map #\S 'j-set-henkan-point)
  (define-key map #\T 'j-set-henkan-point)
  (define-key map #\U 'j-set-henkan-point)
  (define-key map #\V 'j-set-henkan-point)
  (define-key map #\W 'j-set-henkan-point)
  (define-key map #\X 'j-purge-from-jisyo)
  (define-key map #\Y 'j-set-henkan-point)
  (define-key map #\Z 'j-set-henkan-point)
  (define-key map #\[ 'j-self-insert)
  (define-key map #\\ 'j-input-by-code)
  (define-key map #\] 'j-self-insert)
  (define-key map #\^ 'j-self-insert)
  (define-key map #\_ 'j-self-insert)
  (define-key map #\` 'j-self-insert)
  (define-key map #\a 'j-insert-a)
  (define-key map #\b 'j-kana-input)
  (define-key map #\c 'j-kana-input)
  (define-key map #\d 'j-kana-input)
  (define-key map #\e 'j-insert-e)
  (define-key map #\f 'j-kana-input)
  (define-key map #\g 'j-kana-input)
  (define-key map #\h 'j-kana-input)
  (define-key map #\i 'j-insert-i)
  (define-key map #\j 'j-kana-input)
  (define-key map #\k 'j-kana-input)
  (define-key map #\l (if minibuff 'j-mode-off-in-minibuff 'j-mode-off))
  (define-key map #\m 'j-kana-input)
  (define-key map #\n 'j-kana-input)
  (define-key map #\o 'j-kana-input)
  (define-key map #\p 'j-kana-input)
  (define-key map #\q 'j-toggle-kana)
  (define-key map #\r 'j-kana-input)
  (define-key map #\s 'j-kana-input)
  (define-key map #\t 'j-kana-input)
  (define-key map #\u 'j-insert-u)
  (define-key map #\v 'j-kana-input)
  (define-key map #\w 'j-kana-input)
  (define-key map #\x 'j-previous-candidate)
  (define-key map #\y 'j-kana-input)
  (define-key map #\z 'j-kana-input)
  (define-key map #\{ 'j-self-insert)
  (define-key map #\| 'j-self-insert)
  (define-key map #\} 'j-self-insert)
  (define-key map #\~ 'j-self-insert)
  (define-key map #\C-h 'j-delete-backward-char)
  ;;(define-key map #\M-k 'j-katakana-henkan)
  ;;(define-key map #\M-h 'j-hiragana-henkan)
  ;;(define-key map #\M-z 'j-zenkaku-henkan)
  )

(defun j-setup-skk-zenkaku-map ()
  (setq skk-zenkaku-map (j-convert-to-vector j-emacs-local-map))
  (let ((i 0))
    (while (< i 128)
      (if (aref *skk-zenkaku-vector* i)
          (define-key skk-zenkaku-map (code-char i) 'j-zenkaku-insert) )
      (setq i (1+ i)))))

(defun j-setup-skk-abbrev-map ()
  (setq skk-abbrev-map (j-convert-to-vector j-emacs-local-map))
  (define-key skk-abbrev-map #\C-g 'j-keyboard-quit)
  (define-key skk-abbrev-map *skk-kakutei-key* 'j-kakutei)
  (define-key skk-abbrev-map #\TAB 'j-try-completion)
  (define-key skk-abbrev-map #\C-m 'j-newline)
  (define-key skk-abbrev-map #\C-q 'j-zenkaku-henkan)
  (define-key skk-abbrev-map #\. 'j-abbrev-period)
  (define-key skk-abbrev-map #\, 'j-abbrev-comma)
  (define-key skk-abbrev-map #\SPC 'j-start-henkan)
  (define-key skk-abbrev-map #\C-h 'j-delete-backward-char)
  ;;(define-key skk-abbrev-map #\M-z 'j-zenkaku-henkan)
  )

(defun j-self-insert (arg)
  (interactive "P")
  (let ((str (aref *skk-input-vector* (char-code *last-command-char*))))
    (if str
        (let ((count (cond ((not arg) 1)
                           ((symbolp arg) *prefix-args*)
                           ((numberp arg) arg)
                           ((consp arg) (car arg)))))
          (while (> count 0)
            (j-insert-str str)
            (setq count (1- count))))
      (j-emulate-original-map arg))
    (if j-henkan-active (j-kakutei))))

(defun j-zenkaku-insert (&optional (count 1))
  (interactive "p")
  (let* ((str (aref *skk-zenkaku-vector* (char-code *last-command-char*)))
         (len (length str)))
    (while (> count 0)
      (j-insert-str str)
      (setq count (1- count)))))

;; (defun j-zenkaku-self-insert (&optional (count 1))
;;   (interactive "p")
;;   (while (> count 0)
;;     (j-insert-str (j-char-to-string 163 (+ (char-code *last-command-char*) 128)))
;;     (setq count (1- count))))

(defun j-mode-off ()
  "return to old ascii mode."
  (interactive)
  (j-kakutei)
  (setq j-mode nil
        *j-prefix* ""
        j-zenkaku nil)
  (use-keymap j-emacs-local-map)
  (j-change-mode-line *skk-mode-string*))

(defun j-mode-off-in-minibuff ()
  "return to old ascii mode in the minibuffer."
  (interactive)
  (j-kakutei)
  (setq j-mode nil
        *j-prefix* ""
        j-zenkaku nil)
  (use-keymap *j-save-minibuffer-local-map*))

(defun j-zenkaku-eiji ()
  "zenkaku-eiji input"
  (interactive)
  (skk-delete-selection)
  (j-kakutei)
  (setq j-mode nil
        *j-prefix* ""
        j-zenkaku t)
  (use-keymap skk-zenkaku-map)
  (j-change-mode-line *skk-zenei-mode-string*))

(defun j-abbrev-input ()
  (interactive)
  (if (and j-henkan-on (not j-henkan-active)) (error ""))
  (skk-delete-selection)
  (j-kakutei)
  (j-set-henkan-point-subr)
  (use-keymap skk-abbrev-map)
  (setq j-abbrev t))

(defun skk-kill-xyzzy-without-saving-jisyo ()
  (interactive)
  (when (yes-or-no-p "Do you really wish to kill xyzzy without saving Jisyo? ")
    (delete-hook '*kill-xyzzy-hook* 'skk-save-jisyo)
    (kill-xyzzy)))

(defun skk-save-jisyo ()
  "Save jisyo buffer into jisyo file."
  (interactive)
  (if (not *j-jisyo-buffer-modified*)
      (message "No need to save Jisyo.")
    ;; check if the header lines for the two jisyo buffers are ok.
    (progn
      (save-excursion
        (set-buffer (j-get-file-buffer *skk-jisyo*))
        ;; set kanji-fileio-code appropriately
        (skk-set-jisyo-code *skk-jisyo-code*)
        (goto-char (point-min))
        (or (string=
             (buffer-substring
              (point)
              (progn (goto-eol) (point)))
             ";; okuri-ari entries.")
            (skk-search-forward "\n;; okuri-ari entries." nil t)
            (error "Header line for okuri-ari entries is missing!"))
        (unless (skk-search-forward "\n;; okuri-nasi entries." nil t)
          (error "Header line for okuri-nasi entries is missing!")))
      (message "Saving Jisyo...")
      (get-buffer-create " *record*")
      (let* ((*inhibit-quit* t)
             (*skk-jisyo* (merge-pathnames *skk-jisyo*))
             (file-modes (get-file-attributes *skk-jisyo*))
             lines)
        (save-window-excursion
          ;; Originally, call-process was used to execute the Unix mv command.
          (if *skk-backup-jisyo*
              (rename-file *skk-jisyo* *skk-backup-jisyo* :if-exists :overwrite)
            (delete-file *skk-jisyo*))
          (j-create-file *skk-jisyo*)
          (set-file-attributes *skk-jisyo* file-modes)
          (set-buffer (j-get-file-buffer *skk-jisyo*))
          (setq lines (buffer-lines))
          (j-save-jisyo)
          (message "Saving Jisyo...done.")
          (when (and *skk-keep-record* (> *j-count-kakutei* 0))
            (set-buffer " *record*")
            (erase-buffer (selected-buffer))
            (insert-file-contents *skk-record-file*)
            (goto-char (point-min))
            (insert
             (format nil "~A  ìoò^: ~3D  ämíË: ~4D  ämíËó¶: ~3D%  åÍêî: ~6d\n"
                     (format-date-string "%a %b %d %H:%M:%S %Y")
                     *j-count-touroku*
                     *j-count-kakutei*
                     (floor (* 100 (- *j-count-kakutei* *j-count-touroku*))
                            *j-count-kakutei*)
                     lines))
            (write-region (point-min) (point-max) *skk-record-file* nil)
            (set-buffer-modified-p nil))
          (setq *j-count-touroku* 0
                *j-count-kakutei* 0)
          ;; reset *j-jisyo-buffer-modified*
          (setq *j-jisyo-buffer-modified* nil))))))

(defun j-save-jisyo ()
  (let ((go-on t))
    (goto-char (point-min))
    (while go-on
      (set-mark (point))
      (goto-char (+ 50000 (point)))
      (goto-eol)
      (write-region (mark) (point) *skk-jisyo* t)
      (if (eobp) (setq go-on nil)))))

;; input functions

(defun j-newline (&optional (arg 1))
  (interactive "p")
  (let ((no-nl (and *skk-egg-like-newline* j-henkan-on)))
    (if (j-in-minibuffer)
        (progn
          (j-kakutei)
          (unless no-nl
            (setq j-mode nil)
            (minibuffer-exit)))
      (progn
        (if (j-kakutei) (setq arg (1- arg)))
        (unless no-nl
          (j-emulate-original-map arg))))))

(defun j-delete-backward-char (&optional (count 1))
  (interactive "p")
  (if j-okurigana
      (progn
        (setq j-okurigana nil)
        (if (and (char-after j-okurigana-start-point)
                 (char= (char-after j-okurigana-start-point) #\*))
            (skk-delete-region j-okurigana-start-point
                               (1+ (marker-point j-okurigana-start-point))))))
  (if (and j-henkan-on (= (point) (marker-point j-henkan-start-point)))
      (progn
        (setq j-henkan-count 0)
        (j-kakutei))
    (if j-henkan-active
        (let ((p (marker-point j-henkan-end-point)))
          (if (and (not *skk-delete-implies-kakutei*) (= p (point)))
              (j-previous-candidate)
            (progn
              (delete-backward-char count)
              (if (< (point) p) (j-kakutei)))))
      (if (j-in-minibuffer)
          (delete-backward-char count)
        (j-emulate-original-map count)))))

(defun j-input-by-code ()
  "This function lets the user input a JIS character either by its code."
  (interactive)
  (if (interactive-p)
      (insert (j-input-by-code))
    (let ((str (read-string "JIS or SJIS (internal) code: ")))
      (if (string= str "")
          nil ;; PENDING (j-input-by-menu)
        (if (string-matchp "^[0-9a-f]\\{4\\}$" str)
            (let ((code (parse-integer str :radix 16)))
              (if (< code 256)
                  nil ;; PENDING (j-input-by-menu code)
                (multiple-value-bind (b1 b2) (floor code #x100)
                  (if (or (< b1 #x21) (< #x7e b1) (< b2 #x21) (< #x7e b2)) ;; not jis.
                      (code-char code)
                    (skk-jis-code-char code)))))
          (error "Invalid character code. Please enter a 4-hex-digit code."))))))

(defun j-display-code-for-char-at-point ()
  "Displays the code for the charater at the current point."
  (interactive)
  (if (eobp) (error "Cursor is at the end of the buffer."))
  (let* ((char (following-char))
         (code (char-code char))
         (jis (skk-char-jis-code char)))
    (message "`~C'  0x~4,'0X (JIS:0x~4,'0X)" char code jis)))

;; henkan routines

(defun j-toggle-kana (arg)
  (interactive "P")
  (if (and j-henkan-on (not j-henkan-active))
      (j-katakana-henkan arg)
    (progn
      (j-kakutei)
      (setq j-katakana (not j-katakana))
      (j-change-mode-line (if j-katakana
                              *skk-katakana-mode-string*
                            *skk-hirakana-mode-string*)))))

(defun j-set-henkan-point (arg)
  (interactive "P")
  (let* ((normal (upper-case-p *last-command-char*))
         (last-char (if normal
                        (char-downcase *last-command-char*)
                      *last-command-char*))
         (sokuon (and (string= *j-prefix* (string last-char))
                      (char/= last-char #\o)))
         (henkan-active j-henkan-active))
    (if (or (not j-henkan-on) j-henkan-active)
        (if normal
            (j-set-henkan-point-subr)
          (progn
            (when j-henkan-on
              (j-set-henkan-point-subr))
            (if henkan-active
                (j-emulate-original-map arg)
              (j-self-insert arg))))
      (if normal
          ;; prepare for the processing of okurigana if not j-okurigana and
          ;; the preceding character is not a numeric character.
          ;; if the previous char is a special midashi char or a
          ;; numeric character, we assume that the user intended to type the
          ;; last-command-char in lower case.
          (if (and (not j-okurigana)
                   (not
                    (and (not (= (marker-point j-henkan-start-point) (point)))
                         (let ((c (preceding-char)))
                           (or (member c *j-special-midashi-char-list* :test #'eq)
                               (digit-char-p c)
                               (char<= #\ÇO c #\ÇX))))))
              (if *skk-process-okuri-early*
                  (progn
                    (skk-set-marker j-henkan-end-point (point))
                    (setq j-henkan-key
                          (format nil "~A~A~A"
                                  (buffer-substring j-henkan-start-point
                                                    (if sokuon j-kana-start-point (point)))
                                  (if sokuon (if j-katakana "Éb" "Ç¡") "")
                                  (string last-char)))
                    (if sokuon (j-erase-prefix))
                    (insert (if sokuon (if j-katakana #\Éb #\Ç¡) "") #\SPC)
                    (setq *j-prefix* "")
                    (j-henkan)
                    (delete-backward-char (if sokuon 2 1))
                    ;; we set j-kana-start-point here, since the marker may
                    ;; no longer point at the correct position after j-henkan.
                    (skk-set-marker j-kana-start-point (point)))
                (unless (= (marker-point j-henkan-start-point) (point))
                  (when sokuon
                    (j-erase-prefix)
                    (insert (if j-katakana #\Éb #\Ç¡))
                    (setq *j-prefix* ""))
                  (skk-set-marker j-okurigana-start-point (point))
                  (insert #\*)
                  (skk-set-marker j-kana-start-point (point))
                  (setq j-okuri-char (string last-char))
                  (setq j-okurigana t))))
        ;; process special char
        (progn
          (insert last-char)
          (skk-set-marker j-henkan-end-point (point))
          (setq j-henkan-key (buffer-substring j-henkan-start-point (point)))
          (setq j-search-key j-henkan-key)
          (setq *j-prefix* "")
          ;;(insert " ")
          (j-henkan))
        ;;(delete-backward-char 1)
        ))
    (when normal
      (unread-char last-char *keyboard*))))

;; j-katakana-region: modified by Wataru Matsui, 199l.11.19.
;;                    modified by Wataru Matsui, 1992. 1.21.
;;                    modified by Tsugutomo Enami, 1992.9.18.
;;    Arguments can be markers as well as numbers.
;;    Cf. katakana-region in wnn-egg.el, arguments to which
;;    should not be markers.
;;    If vcontract is non-nil, "Ç§ÅJ" is converted to "Éî".
;;    The idea for this function comes from katakana-region in wnn-egg.el.

(defun j-katakana-region (start end &optional vcontract)
  "Convert hiragana\'s in the region between START and END to katakana\'s.
Arguments start and end can be markers as well as numbers.
If vcontract is non-nil, \"Ç§ÅJ\" is converted to \"Éî\"."
  (interactive "r\nP")
  (let ((str (buffer-substring start end)))
    (skk-delete-region start end)
    (insert (map-to-full-width-string
             (map-to-half-width-string str :katakana t :hiragana t)
             :katakana t))))

;; j-hiragana-region: contributed by Wataru Matsui, 1991.11.19.
;;                       modified by Wataru Matsui, 1992. 1.21.
;;                       modified by Tsugutomo Enami, 1992.9.18.
;;    Arguments can be markers as well as numbers.
;;    Cf. hiragana-region in wnn-egg.el, arguments to which
;;    should not be markers.
;;    "Éï" and "Éñ" are not regarded as katakana's, since
;;    they don't have corresponding hiragana's.  If optional
;;    argument vexpand is non-nil, "Éî" is converted to "Ç§ÅJ".
;;    The idea for this function comes from hiragana-region in wnn-egg.el.

(defun j-hiragana-region (start end &optional vexpand)
  "Convert katakana\'s in the region between START and END to hiragana\'s.
Arguments start and end can be markers as well as numbers.
If vexpand is non-nil, \"Éî\" is converted to \"Ç§ÅJ\".
\"Éï\" and \"Éñ\" are left unchanged."
  (interactive "r\nP")
  (let ((str (buffer-substring start end)))
    (skk-delete-region start end)
    (insert (map-to-full-width-string
             (map-to-half-width-string str :katakana t :hiragana t)
             :hiragana t))))

(defun j-zenkaku-region (start end)
  "Convert ascii characters in the region between START and END to the
corresponding zenkaku characters."
  (interactive "r")
  (let ((str (buffer-substring start end)))
    (skk-delete-region start end)
    (insert (map-to-full-width-string str :ascii t))))

(defun j-katakana-henkan (arg)
  "Convert hiragana\'s between henkan start point and
henkan end point into katakana\'s.  Valid only in Å§ mode."
  (interactive "P")
  (if j-henkan-on
      (unless (or j-henkan-active j-katakana)
        (setq j-mode t)
        (or (string= *j-prefix* "") (error ""))
        (when (< (point) (marker-point j-henkan-start-point))
          (error "Henkan end point must be after henkan start point."))
        (save-excursion
          (goto-bol)
          (when (> (point) (marker-point j-henkan-start-point))
            (error "Henkan key may not contain a new line character.")))
        (skk-set-marker j-henkan-end-point (point))
        (j-katakana-region j-henkan-start-point j-henkan-end-point t)
        (or arg (j-kakutei))
        )
    (j-emulate-original-map arg)
    ))

(defun j-hiragana-henkan (arg)
  "Convert katakana\'s between henkan start point and
henkan end point into hiragana\'s.  Valid only in Å§ mode."
  (interactive "P")
  (if j-henkan-on
      (unless (or j-henkan-active (not j-katakana))
        (setq j-mode t)
        (or (string= *j-prefix* "") (error ""))
        (when (< (point) (marker-point j-henkan-start-point))
          (error "Henkan end point must be after henkan start point."))
        (save-excursion
          (goto-bol)
          (when (> (point) (marker-point j-henkan-start-point))
            (error "Henkan key may not contain a new line character.")))
        (skk-set-marker j-henkan-end-point (point))
        (j-hiragana-region j-henkan-start-point j-henkan-end-point t)
        (or arg (j-kakutei))
        )
    (j-emulate-original-map arg)
    ))

(defun j-zenkaku-henkan (arg)
  "Convert hankaku\'s between henkan start point and
henkan end point into zenkaku\'s.  Valid only in Å§ mode."
  (interactive "P")
  (if j-henkan-on
      (unless j-henkan-active
        (setq j-mode t)
        (or (string= *j-prefix* "") (error ""))
        (when (< (point) (marker-point j-henkan-start-point))
          (error "Henkan end point must be after henkan start point."))
        (save-excursion
          (goto-bol)
          (when (> (point) (marker-point j-henkan-start-point))
            (error "Henkan key may not contain a new line character.")))
        (skk-set-marker j-henkan-end-point (point))
        (j-zenkaku-region j-henkan-start-point j-henkan-end-point)
        (or arg (j-kakutei))
        )
    (j-emulate-original-map arg)
    ))

(defun j-start-henkan (&optional (arg 1))
  (interactive "p")
  (if j-henkan-on
      (progn
        (setq j-mode t)
        (if j-henkan-active
            (j-next-candidate)
          (progn
            (or (string= *j-prefix* "") (error ""))
            (when (< (point) (marker-point j-henkan-start-point))
              (error "Henkan end point must be after henkan start point."))
            (save-excursion
              (goto-bol)
              (when (> (point) (marker-point j-henkan-start-point))
                (error "Henkan key may not contain a new line character.")))
            (skk-set-marker j-henkan-end-point (point))
            (setq j-henkan-key
                  (let ((key (buffer-substring j-henkan-start-point j-henkan-end-point)))
                    (substring key 0 (string-match " " key)))
                  j-henkan-vector (vector))
            ;;(insert " ")
            (setq j-search-key (j-compute-numeric-henkan-key))
            (j-henkan)
            ;;(delete-backward-char 1)
            (if (and j-abbrev j-henkan-active) (use-keymap skk-map)))))
    (j-self-insert arg)))

(defun j-set-henkan-point-subr ()
  (interactive)
  (skk-delete-selection)
  (if j-henkan-on (j-kakutei))
  (or (string= *j-prefix* "") (j-erase-prefix))
  (insert #\Å§)
  (unless (string= *j-prefix* "")
    (skk-set-marker j-kana-start-point (point))
    (insert *j-prefix*))
  (setq j-henkan-on t)
  (skk-set-marker j-henkan-start-point (point)))

(defun j-change-marker ()
  (save-excursion
    (goto-char (- (marker-point j-henkan-start-point) *j-kanji-len*))
    (if (looking-at "Å§")
        (progn
          (insert #\Å•)
          (delete-char 1))
      (progn
        (j-kakutei)
        (error "It seems that you have deleted Å§.")))))

(defun j-change-marker-to-white ()
  (save-excursion
    (goto-char (- (marker-point j-henkan-start-point) *j-kanji-len*))
    (if (looking-at "Å•")
        (progn
          (insert #\Å§)
          (delete-char 1))
      (progn
        (goto-char j-henkan-start-point)
        (insert #\Å§)
        (skk-set-marker j-henkan-start-point (point))
        (message "It seems that you have deleted Å•.")))))

;; functions for handling numeric arguments in henkan key.

(defun j-compute-numeric-henkan-key ()
  "return the modified version of j-henkan-key where any consecutive
substring consisting of numeric chars like \"12\" or \"ÇOÇX\" is
replaced by a #."
  (let ((key j-henkan-key)
        p list val)
    (if *skk-use-numeric-conversion*
        (progn
          (with-set-buffer
            (save-excursion
              (set-buffer (get-buffer-create " *skk-work*"))
              (erase-buffer (selected-buffer))
              (insert key)
              (goto-char (point-min))
              (while (re-search-forward "\\([0-9]\\|[ÇO-ÇX]\\)" t)
                (let (num)
                  (goto-char (match-beginning 1))
                  (setq p (point))
                  (while (looking-at "\\([0-9]\\|[ÇO-ÇX]\\)")
                    (if (looking-at "[ÇO-ÇX]")
                        (progn
                          (insert (digit-char (- (char-code (following-char))
                                                 (char-code #\ÇO))))
                          (delete-char 1))
                      (forward-char 1)))
                  (setq num (buffer-substring p (point)))
                  (delete-region p (point))
                  (insert #\#)
                  (setq list (nconc list (list num)))))
              (setq val (buffer-substring (point-min) (point-max)))))
          (setq j-num-list list)
          val)
      key)))

(defun j-num-exp (num type)
  "convert the integer string NUM into a string according to TYPE."
  (let ((fun (cdr (assoc type *skk-num-type-list* :test #'eq))))
    (if fun
        (apply fun (list num))
      num)))

(defun j-zenkaku-num-str (num)
  "convert NUM to the string representing it in zenkaku numerals."
  (if (> (length num) 0)
      (format nil "~A~A" (j-zenkaku-num (aref num 0)) (j-zenkaku-num-str (substring num 1)))
    ""))

(defun j-zenkaku-num (num)
  (cdr (assoc num
              '((#\0 . "ÇO") (#\1 . "ÇP") (#\2 . "ÇQ") (#\3 . "ÇR")
                (#\4 . "ÇS") (#\5 . "ÇT") (#\6 . "ÇU") (#\7 . "ÇV")
                (#\8 . "ÇW") (#\9 . "ÇX"))
              :test #'eq)))

(defun j-kanji-num-str (num)
  "convert NUM to the string representing it in zenkaku kanji numerals."
  (if (> (length num) 0)
      (format nil "~A~A" (j-kanji-num (aref num 0)) (j-kanji-num-str (substring num 1)))
    ""))

(defun j-kanji-num (num)
  (cdr (assoc num
              '((#\0 . "ÅZ") (#\1 . "àÍ") (#\2 . "ìÒ") (#\3 . "éO")
                (#\4 . "él") (#\5 . "å‹") (#\6 . "òZ") (#\7 . "éµ")
                (#\8 . "î™") (#\9 . "ã„"))
              :test #'eq)))

(defun j-kanji-num-str2 (num)
  "convert NUM to the string representing it in kanji.  e.g, 1021 will be
converted to \"êÁìÒè\àÍ\""
  (let ((str (j-kanji-num-str2-subr num)))
    (if (string= "" str) "ÅZ" str)))

(defun j-kanji-num-str2-subr (num &optional silent0)
  "If the optional argument SILENT0 is t, the initial 0 of NUM string
will be supressed."
  (let* ((len (length num))
         (l (substring num 0 1))
         (r (substring num 1))
         (c (schar l 0)))
    (if (string= "" r)
        (if (char= c #\0) "" (j-kanji-num c))
      (progn
        (unless (string= l "0")
          (setq silent0 nil))
        (format nil "~A~A~A"
                (if (or (char= c #\0) (and (string= l "1") (not (= (mod len 4) 1))))
                    ""
                  (j-kanji-num c))
                (if (and (string= l "0") (or silent0 (not (= (mod len 4) 1))))
                    ""
                  (cond ((= (mod len 4) 2) "è\")
                        ((= (mod len 4) 3) "ïS")
                        ((= (mod len 4) 0) "êÁ")
                        ((= len 5) (setq silent0 t) "ñú")
                        ((= len 9) (setq silent0 t) "â≠")
                        ((= len 13) (setq silent0 t) "íõ")
                        ((= len 17) (setq silent0 t) "ãû")
                        (t (error "Too big num!"))))
                (j-kanji-num-str2-subr r silent0))))))

(defun j-shogi-num-str (num)
  "convert NUM to the representation used in Shogi.  e.g., 34 will be
converted to \"ÇRél\"."
  (format nil "~A~A" (j-zenkaku-num (schar num 0)) (j-kanji-num (schar (substring num 1 2) 0))))

(defun j-compute-henkan-vectors ()
  (let ((cont t)
        (stage 1)
        (v1 (vector))
        (v2 (vector))
        (v3 (vector))
        (v4 (vector)))
    (while (and cont (not (eolp)))
      (let ((item (buffer-substring (point)
                                    (progn
                                      (skk-search-forward "/")
                                      (1- (point))))))
        (cond ((not okuri-ari)
               (if (and *skk-process-okuri-early* (char= (aref item 0) #\[))
                   (setq cont nil)
                 (setq v1 (vconcat v1 (list item)))))
              ((and (char= (aref item 0) #\[) (<= stage 2))
               (if (string= item
                            (format nil "\[~A" okurigana))
                   (progn
                     (setq stage 3)
                     (setq v2 (vconcat v2 (vector item))))
                 (progn
                   (setq stage 2)
                   (setq v2 (vconcat v2 (vector item))))))
              ((and (char= (aref item 0) #\]) (= stage 3))
               (setq stage 4)
               (setq v4 (vconcat v4 (vector item))))
              ((= stage 1)
               (setq v1 (vconcat v1 (vector item))))
              ((= stage 2)
               (setq v2 (vconcat v2 (vector item))))
              ((= stage 3)
               (setq v3 (vconcat v3 (vector item))))
              ((= stage 4)
               (setq v4 (vconcat v4 (vector item)))))))
    (list v1 v2 v3 v4)))

(defun skk-list-to-henkan-vectors (lst)
  (let ((stage 1)
        (v1 (vector))
        (v2 (vector))
        (v3 (vector))
        (v4 (vector)))
    (dolist (item lst)
      (cond ((not okuri-ari)
             (if (and *skk-process-okuri-early* (char= (aref item 0) #\[))
                 (return)
               (setq v1 (vconcat v1 (list item)))))
            ((and (char= (aref item 0) #\[) (<= stage 2))
             (if (string= item (format nil "\[~A" okurigana))
                 (progn
                   (setq stage 3)
                   (setq v2 (vconcat v2 (vector item))))
               (progn
                 (setq stage 2)
                 (setq v2 (vconcat v2 (vector item))))))
            ((and (char= (aref item 0) #\]) (= stage 3))
             (setq stage 4)
             (setq v4 (vconcat v4 (vector item))))
            ((= stage 1)
             (setq v1 (vconcat v1 (vector item))))
            ((= stage 2)
             (setq v2 (vconcat v2 (vector item))))
            ((= stage 3)
             (setq v3 (vconcat v3 (vector item))))
            ((= stage 4)
             (setq v4 (vconcat v4 (vector item))))))
    (list v1 v2 v3 v4)))

(defun j-quote-char (word)
  "If WORD contains characters that are normally not part of dictionary
entries, then convert it into a lisp code that will return the word when
it is evaluated."
  (if (and (string-match "[/\n\r\"]" word)
           ;; we should not quote WORD if it is a symbolic expression
           (let ((l (length word)))
             (not
              (and (> l 2)
                   (char= (aref word 0) #\()
                   (char< (aref word 1) #\x80)
                   (char= (aref word (1- l)) #\))))))
      (format nil "(concat \"~A\")"
              (skk-mapconcat #'(lambda (c)
                                 (cond ((eq c #\/) "\\057")
                                       ((eq c #\LFD) "\\n")
                                       ((eq c #\RET) "\\r")
                                       ((eq c #\") "\\\"")
                                       ((eq c #\\) "\\\\")
                                       (t (string c))))
                             (concatenate 'list word) ""))
    word))

(defun j-update-jisyo (file word &optional purge)
  (declare (special word))
  "update jisyo buffer associated to FILE so that WORD will become the first
candidate next time.  If PURGE is t, the word is removed from the jisyo entry."
  ;; if (j-get-file-buffer file) is nil, we have nothing to do
  (if (j-get-file-buffer file)
      (let ((vector1 #())
            (vector2 #())
            (vector3 #())
            (vector4 #())
            (len (length j-henkan-vector))
            (count (1- j-henkan-count))
            (okurigana j-henkan-okurigana)
            (*inhibit-quit* t)
            (new-entry t)
            okuri-ari
            min
            max
            key
            entry-point)
        (declare (special okuri-ari okurigana len))
        ;; we don't have to auto-process okuri if j-num-list is non-nil
        ;; or the first character of j-henkan-key is an ascii character.
        (if (and *skk-auto-okuri-process*
                 (not j-num-list)
                 (kanji-char-p (aref j-henkan-key 0))
                 (or (> j-henkan-count len)
                     (and (< j-okuri-index-min j-henkan-count)
                          (<= j-henkan-count j-okuri-index-max))))
            (j-remove-common))
        ;; we must re-compute okuri-ari, since j-henkan-key might have been
        ;; changed by j-remove-common
        (setq okuri-ari ;; used in j-compute-henkan-vectors
              (let ((char (aref j-henkan-key (1- (length j-henkan-key)))))
                (and (kanji-char-p (aref j-henkan-key 0))
                     (lower-case-p char))))
        (setq key (format nil "~A /" (if okuri-ari j-henkan-key j-search-key)))
        (with-set-buffer
          (save-excursion
            (set-buffer (j-get-file-buffer file))
            (setq min (if okuri-ari j-okuri-ari-min j-okuri-nasi-min))
            (setq max (if okuri-ari j-okuri-ari-max (point-max)))
            ;; we have to backup one character so that we can find key correctly
            ;; even if it is the first entry in the region bounded by min and max
            (goto-char (1- min))
            ;; delete old entry
            (when (skk-search-forward (format nil "\n~A" key) max t)
              (let ((l (j-compute-henkan-vectors)))
                (setq vector1 (nth 0 l)
                      vector2 (nth 1 l)
                      vector3 (nth 2 l)
                      vector4 (nth 3 l)))
              (setq new-entry nil)
              (delete-region
               (progn (goto-bol) (point))
               (progn (goto-eol) (forward-char 1) (point))))
            ;; insert new entry
            (if okuri-ari
                (when new-entry
                  (let (p)
                    (goto-char min)
                    (setq p (point))
                    (while (and (not (= (point) max))
                                (string< key
                                         (progn
                                           (skk-search-forward " /")
                                           (buffer-substring p (point)))))
                      (or (forward-line 1) (goto-eol))
                      (setq p (point)))))
              (goto-char min))
            (goto-bol)
            (setq entry-point (point))
            (insert key
                    (if purge
                        ""
                      (format nil "~A/"
                              (if (and (not new-entry)
                                       *skk-use-numeric-conversion*
                                       j-num-list
                                       (< count (length vector1)))
                                  (setq word (aref vector1 count))
                                (j-quote-char word)))))
            (let ((index 0)
                  (len (length vector1)))
              (while (< index len)
                (let ((w (aref vector1 index)))
                  (unless (string= word w)
                    (insert (j-quote-char w) #\/))
                  (setq index (1+ index)))))
            (when (and okuri-ari (not *skk-process-okuri-early*))
              (let ((index 0)
                    (len (length vector2)))
                (while (< index len)
                  (insert (aref vector2 index) #\/)
                  (setq index (1+ index))))
              (if (zerop (length vector3))
                  (unless purge
                    (insert "\[" okurigana "/" word "/\]/"))
                (let ((index 0)
                      (len (length vector3)))
                  (unless purge
                    (insert word #\/))
                  (while (< index len)
                    (let ((w (aref vector3 index)))
                      (unless (string= word w)
                        (insert w #\/))
                      (setq index (1+ index))))))
              (let ((index 0)
                    (len (length vector4)))
                (when (> len 0)
                  (let ((p (point)))
                    (save-excursion
                      ;(search-backward "/" nil nil 2)
                      (search-backward "/") (search-backward "/")
                      (when (looking-at  "/\\[")
                      (delete-region (1+ (point)) p)
                        (setq index 1)))))
                (while (< index len)
                  (insert (aref vector4 index) #\/)
                  (setq index (1+ index)))))
            (when purge
              (let ((uniq t)
                    (index 0)
                    (l2 (length vector2))
                    (l4 (length vector4)))
                (while (and uniq (< index l2))
                  (if (string= word (aref vector2 index))
                      (setq uniq nil)
                    (setq index (1+ index))))
                (setq index 0)
                (while (and uniq (< index l4))
                  (if (string= word (aref vector4 index))
                      (setq uniq nil)
                    (setq index (1+ index))))
                (when uniq
                  ;; the WORD is not in vector2 nor in vector4, so purge it
                  ;; also from vector1 (if any)
                  (save-excursion
                    (let ((q (point)))
                      (goto-char entry-point)
                      (skk-search-forward " ")
                      (when (skk-search-forward (format nil "/~A/" word) q t)
                        (delete-region (1+ (match-beginning 0))
                                       (match-end 0))))))))
            (insert "\n")
            (or (forward-line -1) (goto-bol))
            (skk-search-forward " /")
            (when (eolp)
              ;; the key has no words for it so delete everything
              (delete-region (save-excursion (goto-bol) (point))
                             (1+ (point))))
            (when okuri-ari
              ;; in this case, we need to reset j-okuri-ari-max and
              ;; j-okuri-nasi-min
              (goto-char min)
              (skk-search-forward "\n;; okuri-nasi")
              (goto-bol)
              (setq j-okuri-ari-max (point))
              (or (forward-line 1) (goto-eol))
              (setq j-okuri-nasi-min (point)))
            (setq *j-jisyo-buffer-modified*
                  (or *j-jisyo-buffer-modified*
                      (buffer-modified-p)))
            (set-buffer-modified-p nil))))))

(defun j-remove-common ()
  "remove trailing common kana ending parts both from midasi and word.
For instance, (Ç‡Ç¡ÇƒÇ´ÇΩ éùÇ¡ÇƒÇ´ÇΩ) -> key := \"Ç‡t /\",
okurigana := \"Ç¡Çƒ\", word := \"éù\""
  (let* ((midasi j-henkan-key)
         (midasi-len (length midasi))
         (word-len (length word))
         (kanji-len2 (* 2 *j-kanji-len*))
         char pos2)
    (when (and (>= midasi-len kanji-len2) (>= word-len kanji-len2))
      ;; check if both midasi and word end with the same ascii char.
      (when (and (string= (substring midasi -1) (substring word -1))
                 (char< (schar (substring midasi -1) 0) #\x80))
        ;; if so chop off the char from midasi and word
        (setq midasi (substring midasi 0 -1)
              midasi-len (1- midasi-len)
              word (substring word 0 -1)
              word-len (1- word-len)))
      (let ((midasi-tail (substring midasi (- midasi-len *j-kanji-len*) midasi-len))
            (word-tail (substring word (- word-len *j-kanji-len*) word-len)))
        (when (and (string= midasi-tail word-tail)
                   (or (and (string<= "Çü" midasi-tail)
                            (string<= midasi-tail "ÇÒ"))
                       (string= "ÅA" midasi-tail)
                       (string= "ÅB" midasi-tail)
                       (string= "ÅC" midasi-tail)
                       (string= "ÅD" midasi-tail)))
          (let ((pos (- word-len *j-kanji-len*))
                (cont t)
                new-word new-j-henkan-key)
            (while (and cont (> pos 0))
              (setq char (substring word (- pos *j-kanji-len*) pos))
              (if (and (string<= "àü" char) (string<= char "Í¢"))
                  ;; char is the right-most Kanji
                  (setq cont nil)
                (setq pos (- pos *j-kanji-len*))))
            (setq pos2 (- midasi-len (- word-len pos)))
            ;; check if midasi and word has the same tail of length
            ;; (- word-len pos)
            (when (string= (substring midasi pos2 midasi-len)
                           (substring word pos word-len))
              (let ((okuri-first (substring word pos (+ pos *j-kanji-len*))))
                (setq okurigana
                      (if (and (string= okuri-first "Ç¡")
                               (<= (+ pos kanji-len2) word-len))
                          ;; in this case okuriga consits of two
                          ;; characters, e.g., ÅuécÇ¡ÇΩÅv
                          (substring word pos (+ pos kanji-len2))
                        okuri-first))
                (setq new-word (substring word 0 pos))
                (setq new-j-henkan-key
                      (format nil "~A~A"
                              (substring midasi 0 pos2)
                              (if (string= okuri-first "ÇÒ")
                                  "n"
                                (if (string= okuri-first "Ç¡")
                                    (aref *skk-kana-rom-vector*
                                          (- (mode (char-code (schar (substring okurigana
                                                                                (1- kanji-len2)
                                                                                kanji-len2)
                                                                     0))
                                                   256)
                                             #x9f))
                                  (aref *skk-kana-rom-vector*
                                        (- (mod (char-code (schar (substring okurigana
                                                                             (1- *j-kanji-len*)
                                                                             *j-kanji-len*)
                                                                  0))
                                                256)
                                           #x9f))))))
                (if (> j-henkan-count len)
                    ;; ask if register as okuri-ari word.
                    (let (;; allow keyboard quit
                          (*inhibit-quit* nil))
                      (when (y-or-n-p
                             (format nil
                              "Shall I register this as okuri-ari entry: ~A /~A/ ? "
                              new-j-henkan-key new-word))
                        (setq word new-word
                              j-henkan-key new-j-henkan-key))
                      (message ""))
                  (setq word new-word
                        j-henkan-key new-j-henkan-key))))))))))

(defun j-henkan ()
  "The main kana-to-kanji conversion routine."
  (let ((eobp (eobp))
        ;; we use mark to go back to the correct position after henkan
        mark new-word-entered)
    (unless eobp
      (forward-char 1)
      (skk-set-marker mark (point)))
    (save-excursion
      (unless j-henkan-active
        (j-change-marker)
        (setq j-henkan-active t
              j-search-prog-list *skk-search-prog-list*))
      (if (string= j-henkan-key "")
          (j-kakutei)
        (let ((found nil)
              (kakutei nil)
              (quit nil)
              (cont t)
              (l1 0)
              (l2 0)
              new-word)
          (declare (special new-word kakutei found quit))
          (if (zerop j-henkan-count)
              (progn
                (when (zerop (length j-henkan-vector))
                  (when (eq *last-command* 'j-undo-kakutei)
                    ;; in this case, we should not search kakutei jisyo.
                    (setq j-search-prog-list (cdr *skk-search-prog-list*)))
                  (setq j-okuri-ari (and (kanji-char-p (aref j-henkan-key 0))
                                         (lower-case-p (aref j-henkan-key (1- (length j-henkan-key)))))
                        j-henkan-vector (j-search)))
                (unless (zerop (length j-henkan-vector))
                  (setq found t
                        j-henkan-count 1
                        new-word (aref j-henkan-vector 0))))
            (progn
              (if (< j-henkan-count (length j-henkan-vector))
                  (setq new-word (aref j-henkan-vector j-henkan-count)
                        found t)
                ;; call j-search repeateldly, until we find new candidates
                ;; or until j-search-prog-list becomes empty
                (progn
                  (while (and j-search-prog-list (= l1 l2))
                    (setq l1 (length j-henkan-vector))
                    (setq j-henkan-vector
                          (j-vector-add j-henkan-vector (j-search)))
                    (setq l2 (length j-henkan-vector)))
                  (when (< j-henkan-count (length j-henkan-vector))
                    (setq new-word (aref j-henkan-vector j-henkan-count)
                          found t))))
              (if (< j-henkan-count 4)
                  (when found
                    (setq j-henkan-count (1+ j-henkan-count)))
                (when found
                  ;; show candidates in minibuffer
                  (j-henkan-show-candidates)))))
          (unless quit
            (if found
                (progn
                  (skk-delete-region j-henkan-start-point j-henkan-end-point)
                  (goto-char j-henkan-start-point)
                  (j-insert-word new-word)
                  (skk-set-marker j-henkan-end-point (point))
                  (when kakutei
                    (let ((*j-prefix* *j-prefix*))
                      ;; save and restore *j-prefix* after j-kakutei
                      (j-kakutei new-word))))
              ;; use recursive minibuffer
              (let ((save-start (skk-copy-marker j-henkan-start-point))
                    (save-end (skk-copy-marker j-henkan-end-point))
                    (*enable-recursive-minibuffers* t) ; Added by IIDA
                    ;; inhibit isearch message while doing henkan
                    (*skk-isearch-message* nil))
                (declare (special save-start))
                (setq new-word-entered (j-henkan-in-minibuff))
                (skk-set-marker j-henkan-start-point save-start)
                (skk-set-marker j-henkan-end-point save-end)
                (when new-word-entered
                  (skk-delete-region j-henkan-start-point j-henkan-end-point)
                  (goto-char j-henkan-start-point)
                  (j-insert-word new-word)
                  (skk-set-marker j-henkan-end-point (point))
                  (when kakutei
                    (let ((*j-prefix* *j-prefix*))
                      ;; save and restore *j-prefix* after
                      ;; j-kakutei
                      (j-kakutei new-word))))))))))
    (if eobp
        (goto-char (point-max))
      (progn
        (goto-char mark)
        (unless (and overwrite-mode new-word-entered)
          (backward-char 1))))))

(defun j-insert-word (word)
  "Insert WORD at point.  If *skk-use-numeric-conversion* is t, WORD will
be modified using j-num-list, and the the modified word will be inserted."
  (when (and *skk-use-numeric-conversion* j-num-list)
    (setq word (j-numeric-convert word)))
  (setq word (j-split-annotation word))
  (insert (car word))
  (when (cadr word)
    (popup-string (cadr word) (point))))

(defun j-split-annotation (word)
  (let (annotation
        (f (lambda (word)
             (if (string-match "^(.*)$" word)
                 (handler-case
                     (let ((*package* *package*))
                       (in-package "skk")
                       (eval (read-from-string word)))
                   (quit (c) word)
                   (error (c) word))
               word))))
    (setq word
          (if (string-match "^\\(.*\\);\\(.*\\)$" word)
              (let ((s2 (match-string 2))
                    (s1 (match-string 1)))
                (setq annotation (funcall f s2))
                (funcall f s1))
            (funcall f word)))
    (setq annotation
          (and *skk-show-annotation*
               (if *skk-annotation-function*
                   (funcall *skk-annotation-function* annotatiotion)
                 t)
               annotation))
    (list word annotation)))

(defun j-search ()
  "search j-henkan-key using the programs in the list j-search-prog-list."
  (let ((v #()))
    (while (and (zerop (length v)) j-search-prog-list)
      (setq v (eval (car j-search-prog-list))
            j-search-prog-list (cdr j-search-prog-list) ))
    v ))

(defun j-search-jisyo-file (file limit &optional nomsg)
  "search henkan-key in skk format jisyo file FILE.  binary search is
performed until the search region becomes less than LIMIT, and then
switch to linear search.  if LIMIT is 0, only linear search is done.
if the jisyo file is not sorted, you should set LIMT to be 0.  optional
argument NOMSG, if t, supresses the message."
  (let (ari-min ari-max nasi-min)
    (if file
        (progn
          (j-get-file-buffer file nomsg)
          (with-set-buffer
            (save-excursion
              (set-buffer (j-get-file-buffer file))
              (setq ari-min j-okuri-ari-min
                    ari-max j-okuri-ari-max
                    nasi-min j-okuri-nasi-min)))
          (j-search-sorted-buffer
           (if j-okuri-ari j-henkan-key j-search-key)
           (j-get-file-buffer file)
           limit
           (if j-okuri-ari ari-min nasi-min)
           (if j-okuri-ari ari-max nil)
           (if j-okuri-ari t nil)))
      #())))

(defun j-get-file-buffer (file &optional nomsg)
  "Create a unique buffer for skk formated FILE and initialize some
local variables."
  (setq file (truename file))
  (if (find-name-buffer (format nil " *skk:~A*" file))
      (car (find-name-buffer (format nil " *skk:~A*" file)))
    (with-set-buffer
      (save-excursion
        (setq file (merge-pathnames file))
        (set-buffer
         (create-new-buffer
          (format nil " *skk:~A*" file)))
        ;(set-buffer-file-name file)
        ;(setq *case-fold-search* nil)
        (make-local-variable 'kept-undo-information)
        (setq kept-undo-information nil)
        (unless nomsg
          (message "Inserting contents of ~A ..."
                   (skk-file-name-nondirectory file)))
        (insert-file-contents file)
        (unless nomsg
          (message "Inserting contents of ~A ...done"
                   (skk-file-name-nondirectory file)))
        (set-buffer-modified-p nil)
        (when (= (point-min) (point-max))
          ;; if the file is empty, we make it a minimal well
          ;; formed skk jisyo
          (insert ";; okuri-ari entries.\n"
                  ";; okuri-nasi entries.\n"))
        (goto-char (point-min))
        (if (skk-search-forward ";; okuri-ari entries.\n" nil t)
            (progn
              (make-local-variable 'j-okuri-ari-min)
              (make-local-variable 'j-okuri-ari-max)
              (make-local-variable 'j-okuri-nasi-min)
              (setq j-okuri-ari-min (point))
              (backward-char 1)
              (if (skk-search-forward "\n;; okuri-nasi entries." nil t)
                  (progn
                    (goto-bol)
                    (setq j-okuri-ari-max (point))
                    (goto-eol)
                    (setq j-okuri-nasi-min (1+ (point))))
                (error "%s is not well formed!" file)))
          (error "%s is not well formed!" file))
        (selected-buffer)))))

(defun j-search-kakutei-jisyo-file (file limit &optional nomsg)
  "search jisyo file, and return the first candidate as a string.  if no
candidates are found, return an empty vector."
  (let ((v (j-search-jisyo-file file limit nomsg)))
    (if (zerop (length v))
        #()
      (aref v 0))))

(defun j-search-sorted-buffer (key buffer limit &optional min max reverse)
  "search KEY in BUFFER which is assumed to be sorted. try binary
search first until the size of the search region becomes less than LIMIT.
If LIMIT is 0, only linear seach is done.  optional arguments MIN and MAX
bounds the search region.  if the optional argument REVERSE is t,
comparison will be done by reversed order."
  (let ((okurigana j-henkan-okurigana) ;; used in j-compute-henkan-vectors
        (okuri-ari j-okuri-ari) ;; used in j-compute-henkan-vectors
        ;; when merge-all-entry is nil, only the entry with strcitly
        ;; matched okurigana is returned.
        (merge-all-entry (or (not j-okuri-ari) (not *j-henkan-okuri-strictly*)))
        size p l)
    (declare (special okuri-ari okurigana))
    (with-set-buffer
      (save-excursion
        (set-buffer buffer)
        (setq min (or min (point-min))
              max (or max (point-max))
              size (- max min))
        (when (> limit 0)
          (while (> size limit)
            (goto-char (+ min (floor size 2)))
            (goto-bol)
            (setq p (point))
            (if (if reverse
                    (string<
                     (buffer-substring
                      p
                      (progn (skk-search-forward " ") (1- (point))))
                     key)
                  (string<
                   key
                   (buffer-substring
                    p
                    (progn (skk-search-forward " ") (1- (point))))))
                (setq max p)
              (setq min p))
            (setq size (- max min)) ))
        (goto-char min)
        ;; backup one character so that we can find the key correctly even
        ;; if the key is at the beginning of the search region.
        (unless (bobp)
          (backward-char 1))
        (let ((w (format nil "\n~A /" key))
              ;(*case-fold-search* nil)
              )
          (setq l (if (skk-search-forward w max t)
                      (j-compute-henkan-vectors)
                    '(#() #() #() #()) )))
        (if merge-all-entry
            (j-vector-add (nth 2 l) (nth 0 l))
          (nth 2 l) )))))

(defun j-okuri-search ()
  (let (v)
    (if (and
         (not j-abbrev)
         *skk-auto-okuri-process*
         (not *skk-process-okuri-early*)
         (not j-okuri-ari)
         ;; we don't do auto-okuri-process if henkan key
         ;; contains numerals
         (not j-num-list)
         (> (length j-henkan-key) 1))
        (progn
          (setq j-okuri-index-min (length j-henkan-vector))
          (setq v (j-okuri-search-subr))
          (setq j-okuri-index-max (+ j-okuri-index-min (length v)))
          v)
      #())))

(defun j-okuri-search-subr ()
  (let* ((henkan-key j-henkan-key)
         (key (substring henkan-key 0 (if *skk-mule* 3 2)))
         (len (length henkan-key))
         (key1 (format nil "\n~A" key))
         key2 len2
         key3 len3 okuri3
         (*inhibit-quit* t)
         p q r s
         (v (vector))
         )
    (with-set-buffer
      (save-excursion
        (set-buffer (j-get-file-buffer *skk-jisyo*))
        (goto-char (1- j-okuri-ari-min))
        (while (skk-search-forward key1 j-okuri-ari-max t)
          (setq p (point))
          (skk-search-forward " ")
          (setq key2 (format nil "~A~A" key (buffer-substring p (- (point) 2)))
                len2 (length key2))
          (when (and (<= len2 len)
                     (string= key2 (substring henkan-key 0 len2)) )
            (let ((cont t))
              (save-excursion
                (goto-eol)
                (setq q (point)))
              (while (and cont
                        (skk-search-forward "/[" q t))
                (setq r (point))
                (skk-search-forward "/")
                (setq okuri3 (buffer-substring r (1- (point)))
                      key3 (format nil "~A~A" key2 okuri3)
                      len3 (length key3))
                (when (and (<= len3 len)
                           (string= key3 (substring henkan-key 0 len3)) )
                  ;; finally found a candidate!
                  (let ((okuri (format nil "~A~A" okuri3 (substring henkan-key len3 len))))
                    (while
                        (not (looking-at "\]"))
                      (setq s (point))
                      (skk-search-forward "/" j-okuri-ari-max t)
                      (setq v (vconcat v
                                       (vector
                                        (format nil "~A~A"
                                                (buffer-substring s (1- (point)))
                                                okuri)))))
                    ;; it is not necessary to seach for "\[" on this line
                    ;; any more
                    (setq cont nil)))))))
        v))))

(defun j-numeric-convert (word)
  "If j-num-list is non-nil, convert WORD by substituting appropriate strings
for the occurrences of # in the WORD."
  (let ((list j-num-list)
        num)
    (if list
        (with-set-buffer
          (save-excursion
            (set-buffer (get-buffer-create " *skk-work*"))
            (erase-buffer (selected-buffer))
            (insert word)
            (goto-char (point-min))
            (while (and list (skk-search-forward "#" nil t))
              (setq num (car list))
              (let ((char (following-char)))
                (delete-region (1- (point)) (1+ (point)))
                (insert (j-num-exp num char))
                (setq list (cdr list))))
            (buffer-substring (point-min) (point-max))))
      word)))

(defun skk-sub-henkan-vector (henkan-vector start len)
  (let ((max (min (+ start len) (length henkan-vector)))
        lst)
    (do ((i (1- max) (1- i)))
        ((< i start) lst)
      (push (j-aref henkan-vector i) lst))))

(defun j-henkan-show-candidates (&optional (h-start 4))
  "Show candidates in the minibuffer."
  (let ((cont t)
        (count 1)
        (l (length j-henkan-vector)))
    (setq found t)
    (skk-delete-region j-henkan-start-point j-henkan-end-point)
    (let ((h-count j-henkan-count)
          (unread nil)
          ;; Added following to enable interruption while executing
          ;; skk-isearch.
          (*inhibit-quit* nil))
      ;(declare (special h-count))
      (save-excursion
        (while (and j-search-prog-list (< (- l h-count) 7))
          (setq j-henkan-vector (j-vector-add j-henkan-vector (j-search))
                l (length j-henkan-vector)))
        (when (= h-count l)
          (setq cont nil found nil))
        (while cont
          (while (and j-search-prog-list (< (- l h-count) 7))
            (setq j-henkan-vector (j-vector-add j-henkan-vector (j-search))
                  l (length j-henkan-vector)))
          (if (= h-count l)
              (setq cont nil)
            (progn
              (let* ((lst1 (skk-sub-henkan-vector j-henkan-vector h-count 7))
                     (lst2 (mapcar (lambda (x y)
                                     (let ((word (j-split-annotation x)))
                                       (cons (format nil "~C:~A" (char-upcase y) (car word))
                                             (cdr word))))
                                   lst1 *j-henkan-show-candidates-keys*))
                     (rest (format nil "[écÇË ~D~A]"
                                   (1+ (- l (+ h-count (setq count (min 8 (1+ (- l h-count)))))))
                                   (skk-make-string (length j-search-prog-list) #\+))))
                (message "~A  ~A"
                         (skk-joinstr " " (mapcar (lambda (x) (if (consp x) (car x) x)) lst2))
                         rest)
                (when *skk-show-annotation*
                  (popup-string (concat
                                 (skk-joinstr "\n"
                                              (mapcar (lambda (x)
                                                        (if (consp x)
                                                            (if (cadr x)
                                                                (concat (car x) "   " (cadr x))
                                                              (car x))
                                                          x))
                                                      lst2))
                                 "\n  " rest)
                                j-henkan-start-point)))
              (incf h-count (1- count))
              (handler-case
                  (let* ((char (read-char *keyboard*))
                         (char-val-pair (assoc char
                                               (let ((nth 0))
                                                 (mapcar (lambda (x) (prog1 (cons x nth) (incf nth))) *j-henkan-show-candidates-keys*))
                                               :test #'char=)))
                    (cond (char-val-pair
                           (let ((c (cdr char-val-pair)))
                             (if (> (+ c 2) count)
                                 (progn
                                   (message "`~C' is not valid here!" char)
                                   (sit-for 1)
                                   (message "")
                                   (setq h-count
                                         (- h-count (1- count))))
                               (progn
                                 (skk-erase-popup)
                                 (setq h-count (+ (- h-count count) c 2)
                                       new-word (car (split-string (aref j-henkan-vector (1- h-count)) #\;))
                                       kakutei t
                                       cont nil)))))
                          ((char= char #\x)
                           (let* ((a (floor (- h-count (1+ h-start)) 7))
                                  (b (- h-count (+ h-start (* 7 a)))))
                             (if (zerop a)
                                 (setq h-count (- h-count (1- b))
                                       cont nil
                                       unread t)
                               (setq h-count (- (- h-count b) 7)))))
                          ((char= char #\SPC)
                           (if (and (= h-count l) (null j-search-prog-list))
                               ;; no more candidates
                               (setq cont nil found nil)))
                          ((char= char #\C-g) (quit))
                          (t
                           (message "`~C' is not valid here!" char)
                           (sit-for 1)
                           (message "")
                           (setq h-count (- h-count (1- count))))))
                (quit (c)
                  (setq h-count 1 cont nil unread t)))))))
      (when unread
        (unread-char #\x *keyboard*)
        (setq quit t))
      (setq j-henkan-count h-count))))

(defvar *j-save-minibuffer-local-map* nil)

(defun j-henkan-in-minibuff ()
  (setq new-word
        (let (r-word
              (h-count j-henkan-count))
          ;(declare (special h-count))
          (handler-case
              (setq r-word
                    (let ((*j-save-minibuffer-local-map* minibuffer-local-map)
                          (minibuffer-local-map (progn
                                                  (j-setup-skk-minibuff-map)
                                                  *skk-minibuff-map*)))
                      (declare (special minibuffer-local-map))
                      (read-string
                       (format nil "~A "
                        (if j-num-list
                            j-search-key
                          (or j-henkan-key2 j-henkan-key))))))
            (quit (c)
              (setq r-word "")))
          (setq j-henkan-count h-count)
          r-word))
  (if (string= new-word "")
      (cond ((> j-henkan-count 4)
             (let* ((a (floor (- j-henkan-count 5) 7))
                    (b (- j-henkan-count (+ 4 (* 7 a)))))
               (setq j-henkan-count (- j-henkan-count b))
               (j-henkan)))
            ((zerop j-henkan-count)
             (setq j-henkan-active nil
                   j-henkan-key2 nil
                   )
             (let ((j-henkan-start-point save-start))
               (declare (special j-henkan-start-point))
               (j-change-marker-to-white)))
            (t nil))
    (progn
      (setq kakutei t)
      (setq *j-count-touroku* (1+ *j-count-touroku*))
      (setq j-henkan-count (1+ j-henkan-count))))
  (not (string= new-word "")))

(defun j-aref (vector index)
  "Get the element of VECTOR at index INDEX.  If *skk-use-numeric-conversion*
is t, modify the result appropriately using j-num-list."
  (let ((word (aref vector index)))
    (if (and *skk-use-numeric-conversion* j-num-list)
        (j-numeric-convert word)
      word)))

(defun j-next-candidate ()
  "Show next henkan candidate."
  (when j-henkan-active
    ;;(insert " ")
    (j-henkan)
    ;;(delete-backward-char 1)
    ))

(defun j-previous-candidate ()
  "Show previous henkan candidate."
  (interactive)
  (if (and j-henkan-active (not (string= j-henkan-key "")))
      (progn
        (insert #\SPC)
        (let ((word (format nil "~A " j-henkan-key))
              (found nil)
              new-word p q)
          (declare (special found new-word))
          (save-excursion
            (cond ((= j-henkan-count 1)
                   (setq j-henkan-active nil
                         j-henkan-count 0
                         j-okuri-index-min 0
                         j-okuri-index-max 0
                         j-henkan-vector #()
                         j-okurigana nil
                         j-henkan-okurigana nil
                         j-henkan-key2 nil
                         j-num-list nil)
                   (setq q (point-marker))
                   (skk-delete-region j-henkan-start-point j-henkan-end-point)
                   (goto-char j-henkan-end-point)
                   (insert j-henkan-key)
                   (when (> (length *j-prefix*) 0)
                     (skk-set-marker j-kana-start-point (point)))
                   (setq p (point-marker))
                   (goto-char j-henkan-start-point)
                   (if (kanji-char-p (following-char))
                       (progn
                         ;; roman prefix for okurigana is removed
                         (while (and (< (point) (marker-point p))
                                     (kanji-char-p (following-char)))
                           (forward-char 1))
                         (when (lower-case-p (following-char))
                           (skk-delete-region (point) p)))
                     (goto-char p))
                   (j-change-marker-to-white))
                  ((<= j-henkan-count 7)
                   (setq word (aref j-henkan-vector (- j-henkan-count 2)))
                   (skk-delete-region j-henkan-start-point j-henkan-end-point)
                   (goto-char j-henkan-end-point)
                   (j-insert-word word)
                   (skk-set-marker j-henkan-end-point (point))
                   (setq j-henkan-count (1- j-henkan-count)))
                  ((< 7 j-henkan-count)
                   (setq j-henkan-count (- j-henkan-count 8))
                   (unread-char #\SPC *keyboard*))))
          (when (and (> (point) 0) (char= (preceding-char) #\SPC))
            (delete-backward-char 1))
          (when (zerop j-henkan-count)
            (if *skk-auto-okuri-process* (goto-char q) (goto-char p))
            (when j-abbrev
              (use-keymap skk-abbrev-map)))))
    (if (eq *last-command* 'j-kakutei-henkan)
        ;; restore the state just before the last kakutei henkan.
        (progn
          (skk-delete-region j-henkan-start-point (point))
          (j-set-henkan-point-subr)
          (insert *j-kakutei-key*)
          (setq *this-command* 'j-undo-kakutei))
      (j-kana-input))))

(defun j-keyboard-quit ()
  "If j-henkan-active, abort showing henkan candidates and return to the
j-henkan-on status. If j-henkan-on, delete region between current point and
j-henkan-start-point. Otherwise same as keyboard-quit"
  (interactive)
  (when (string= j-henkan-key "")
    (if (j-in-minibuffer)
        (quit-recursive-edit)
      (quit))) ; <- (keyboard-quit)
  (if j-henkan-active
      (if (and *skk-delete-okuri-when-quit* j-okuri-ari)
          (let ((p (point-marker)))
            (setq j-henkan-count 1)
            (j-previous-candidate)
            (skk-delete-region p (point)))
        (progn
          (setq j-henkan-count 1)
          (j-previous-candidate)))
    (if j-henkan-on
        (progn
          (when (> (point) (marker-point j-henkan-start-point))
            (skk-delete-region (point) j-henkan-start-point))
          (j-kakutei))
      (if (j-in-minibuffer)
          (quit-recursive-edit)
        (quit))))) ; <- (keyboard-quit)

(defun j-kakutei (&optional word)
  "This function does what it says. If WORD is given, it is used as the new
word for jisyo update."
  (interactive)
  (let ((*inhibit-quit* t))
    (if skk-mode
        (progn
          (j-change-mode-line (if j-katakana
                                  *skk-katakana-mode-string*
                                *skk-hirakana-mode-string*))
          (use-keymap skk-map))
      ;; if skk-mode has not been called in this buffer, call it now.
      (skk-mode 1))
    (setq j-mode t
          *j-prefix* "")
    (when j-henkan-on
      (when (and j-henkan-active (> j-henkan-count 0))
        (j-update-jisyo *skk-jisyo* (or word (aref j-henkan-vector (1- j-henkan-count))))
        (setq *j-count-kakutei* (1+ *j-count-kakutei*)))
      (save-excursion
        (goto-char (- (marker-point j-henkan-start-point) *j-kanji-len*))
        (if j-henkan-active
            (if (looking-at "Å•")
                (delete-char 1)
              (message "It seems that you have deleted Å•."))
          (if (looking-at "Å§")
              (delete-char 1)
            (message "It seems that you have deleted Å§.")))
        (when j-okurigana
          (goto-char j-okurigana-start-point)
          (when (looking-at "*")
            (delete-char 1))
          (setq j-okurigana nil)))
      (when overwrite-mode
        (j-del-char-with-pad
         (j-ovwrt-len
          (length
           (buffer-substring j-henkan-start-point (point))))))
      (setq j-abbrev nil))
    (setq j-henkan-active nil
          j-henkan-on nil
          j-okurigana nil
          j-okuri-char ""
          j-henkan-key nil
          j-henkan-key2 nil
          j-henkan-okurigana nil
          j-henkan-vector #()
          j-henkan-count 0
          j-search-key nil
          j-okuri-index-min 0
          j-okuri-index-max 0
          j-num-list nil)
    (j-do-auto-fill)))

;; completion

(defun j-completion (first)
  (let ((cont t)
        c-word p)
    (when first
      (setq *j-completion-word* (buffer-substring j-henkan-start-point (point)))
      (when (string= *j-completion-word* "")
        (error "Cannot complete an empty string!")))
    (catch 'found
      (let ((*inhibit-quit* t)
            ;; completion word is assumed to be a JIS Kanji word if it begins
            ;; with a JIS character
            (jis-completion-word (kanji-char-p (aref *j-completion-word* 0))))
        (with-set-buffer
          (save-excursion
            (set-buffer (j-get-file-buffer *skk-jisyo*))
            (when first
              (goto-char j-okuri-nasi-min))
            (while (scan-buffer (format nil "^~A" (regexp-quote *j-completion-word*))
                                :regexp t
                                :limit (point-max)
                                :tail t)
              (unless (looking-at " /")
                (setq p (point))
                (skk-search-forward " /")
                (setq c-word (format nil "~A~A" *j-completion-word* (buffer-substring p (- (point) 2))))
                ;; if the c-word begins with a JIS character, we must check
                ;; if it ends with an ascii character.  if it indeed ends
                ;; with an ascii character we should ignore it.
                (and jis-completion-word
                     (not (kanji-char-p (aref c-word (1- (length c-word)))))
                     (setq c-word nil))
                (when c-word
                  (throw 'found c-word)))))))
      (message "No ~Acompletions for \"~A\""
               (if first "" "more ") *j-completion-word*)
      (ding))
    (when c-word
      (skk-delete-region j-henkan-start-point (point))
      (insert c-word))))

(defun j-try-completion (arg)
  (interactive "P")
  (if (and j-henkan-on (not j-henkan-active))
      (progn
        (setq *this-command* 'j-completion)
        (j-completion
         (not
          (and *skk-dabbrev-like-completion* (eq *last-command* 'j-completion)))))
    (j-emulate-original-map arg)))

(defun j-abbrev-period (arg)
  (interactive "P")
  (if (eq *last-command* 'j-completion)
      (progn
        (setq *this-command* 'j-completion)
        (j-completion nil))
    (j-emulate-original-map arg)))

(defun j-abbrev-comma (arg)
  (interactive "P")
  (if (eq *last-command* 'j-completion)
      (j-previous-completion)
    (j-emulate-original-map arg)))

(defun j-command-key-sequence (key command)
  "Remove initial sequence of universal arguments from KEY and return
the real key sequence that invoked COMMAND.  If COMMAND is invoked by
`execute-extended-command', nil is returned."
  (while (not (or (zerop (length key))
                  (eq command (lookup-key-command key))))
    (setq key (substring key 1)))
  (and (not (zerop (length key))) key))

(defun j-emulate-original-map (arg)
  (let (;(prefix-arg arg)
        (local-map (local-keymap))
        ;(keys (j-command-key-sequence (this-command-keys) this-command))
        (keys *last-command-char*)
        (buf (selected-buffer)))
    (if (null keys)
        ;; no alternative commands.  may be invoked by M-x.
        nil
      (unwind-protect
          (progn
            (use-keymap (if (j-in-minibuffer) *j-save-minibuffer-local-map* j-emacs-local-map))
            (let ((command (lookup-key-command keys)))
              (if (eq command *this-command*)
                  ;; avoid recursive calling of j-emulate-original-map.
                  nil
                ;; if no bindings are found, call `undefined'.  it's
                ;; original behaviour.
                (command-execute (or command (function undefined))))))
        ;; restore skk keymap.
        (with-set-buffer
          (save-excursion
            (set-buffer buf)
            (use-keymap local-map)))))))

(defun j-previous-completion ()
  (let ((*inhibit-quit* t)
        ;; completion word is assumed to be a JIS Kanji word if it begins
        ;; with a JIS character
        (jis-completion-word (kanji-char-p (aref *j-completion-word* 0)))
        (c-word nil)
        p)
    (with-set-buffer
      (save-excursion
        (set-buffer (j-get-file-buffer *skk-jisyo*))
        (goto-bol)
        (let ((cont t))
          (while (and cont
                      (not (bobp))
                      (unless (scan-buffer (format nil "^~A" *j-completion-word*)
                                           :reverse t
                                           :regexp t
                                           :no-dup t
                                           :limit j-okuri-nasi-min)
                        (goto-char (point-min))
                        (looking-at (regexp-quote *j-completion-word*))))
            (skk-search-forward *j-completion-word*)
            (if (not (looking-at " /"))
                (progn
                  (setq p (point))
                  (skk-search-forward " /")
                  (setq c-word (format nil "~A~A" *j-completion-word* (buffer-substring p (- (point) 2))))
                  ;; if the c-word begins with a JIS character, we must check
                  ;; if it ends with an ascii character.  if it indeed ends
                  ;; with an ascii character we should ignore it.
                  (if jis-completion-word
                      (if (kanji-char-p (aref c-word (1- (length c-word))))
                          (setq cont nil)
                        (progn
                          (setq c-word nil)
                          (goto-bol)))
                    (setq cont nil)))
              (goto-bol))))))
    (skk-delete-region j-henkan-start-point (point))
    (if c-word
        (insert c-word)
      (progn
        (insert *j-completion-word*)
        (message "No more previous completions.")
        (ding)))
    (setq *this-command* 'j-completion)))

(defun j-purge-from-jisyo ()
  "Purge wrong words from jisyo buffer."
  (interactive)
  (when (and j-henkan-active (not (string= j-henkan-key ""))
             (yes-or-no-p "Really purge? "))
    (j-update-jisyo *skk-jisyo* (aref j-henkan-vector (1- j-henkan-count)) t)
    (skk-delete-region j-henkan-start-point j-henkan-end-point)
    (j-change-marker-to-white)
    (setq j-henkan-active nil)
    (j-kakutei)))

;; skk server related functions

(defun skk-dserver (host &optional (port 1178))
  (connect host port))

(defun skk-dserver-send-command (conn str)
  (format conn "~A~%" str))

(defun skk-dserver-read (conn)
  (let (lst c)
    (while (and (char/= #\SPC (setq c (read-char conn t)))
                (char/= #\LFD c))
      (setq lst (cons c lst)))
    (concatenate 'string (reverse lst))))

(defun skk-dserver-read-line (conn)
  (read-line conn t))

(defun skk-dserver-end (conn)
  (skk-dserver-send-command conn "0")
  (close conn))

(defun skk-dserver-request (conn str)
  (skk-dserver-send-command conn (map-internal-to-euc (format nil "1~A " str)))
  (let ((result (map-euc-to-internal (skk-dserver-read-line conn))))
    (when (char= #\1 (schar result 0))
      (cdr (split-string result #\/)))))

(defun skk-dserver-version (conn)
  (skk-dserver-send-command conn "2")
  (skk-dserver-read conn))

(defun skk-dserver-host (conn)
  (skk-dserver-send-command conn "3")
  (split-string (skk-dserver-read conn) #\:))

(defun skk-dserver-open-p (conn)
  (and (streamp conn) (open-stream-p conn)))

(defun skk-dserver-disconnect ()
  (when (skk-dserver-open-p *skk-dserver-connection*)
    (skk-dserver-end *skk-dserver-connection*))
  t)

(defun j-open-server ()
  "Establish connection with skk server."
  (unless (skk-dserver-open-p *skk-dserver-connection*)
    (when (null *skk-server-list*)
      (setq *skk-server-list* (list (cons *skk-server-host* *skk-serv*))))
    (let (succ)
      (while (and (null succ) *skk-server-list*)
        (setq *skk-server-host* (caar *skk-server-list*)
              *skk-serv* (cdar *skk-server-list*)
              *skk-server-list* (cdr *skk-server-list*))
        (if (j-open-server-subr)
            (setq succ t)))
      (if succ
          nil
        (progn
          (message "Could not activate SKK SERVER on ~A." *skk-server-host*)
          (sit-for 1)
          (setq *skk-server-host* nil)
          (ding))))))

(defun j-open-server-subr ()
  (handler-case
      (setq *skk-dserver-connection*
            (skk-dserver *skk-server-host* (or *skk-portnum* 1178)))
    (error (c)
      nil)))

(defun j-search-server (file limit &optional nomsg)
  "seach for henkan-key through skkserver. if server is not up, FILE is
used instead."
  (if (or *skk-server-list* *skk-server-host*)
      (j-search-server-subr file limit)
    (j-search-jisyo-file file limit nomsg)))

(defun j-search-server-subr (file limit)
    "search for henkan-key through skkserver and create the vector of
candidates.  if server is not available, search FILE instead."
  (let ((key (if j-okuri-ari j-henkan-key j-search-key))
        (okurigana j-henkan-okurigana) ;; passed to j-compute-henkan-vectors
        (okuri-ari j-okuri-ari) ;; used in j-compute-henkan-vectors
        ;; when merge-all-entry is nil, only the entry with strcitly
        ;; matched okurigana is returned.
        (merge-all-entry (or (not j-okuri-ari) (not *j-henkan-okuri-strictly*)))
        (v (vector)))
    (declare (special okurigana okuri-ari))
    (j-open-server)
    (if (skk-dserver-open-p *skk-dserver-connection*)
        (let ((result (skk-dserver-request *skk-dserver-connection* key)))
          (if result
              (let ((l (skk-list-to-henkan-vectors result)))
                (if merge-all-entry
                    (j-vector-add (nth 0 l) (nth 2 l))
                  (nth 2 l)))
            #()))
      (j-search-jisyo-file file limit))))

(defun j-vector-add (u v)
  "Concatenate U and elements of V not in U."
  (concatenate 'vector u (remove-if #'(lambda (x) (find x u :test #'string=)) v)))

(defun j-create-file (file &optional message)
  "Create an empty file named FILE if the file FILE does not exist already."
  (let ((file (merge-pathnames file)))
    (unless (file-exist-p file)
      (write-region (point-min) (point-min) file nil)
      (when message
        (message message)
        (sit-for 3)))))

(add-hook '*kill-xyzzy-hook* 'skk-save-jisyo)
(add-hook '*kill-xyzzy-hook* 'skk-dserver-disconnect)

(provide "skk/skk")

;; skk.l ends here.
