;;; skk-sticky.l

;; Copyright (c) 2006 SANO Masatoshi

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "skk/skk"))
(in-package "skk")

(defvar *sticky-list-ascii*
  '(("a" . "A")("b" . "B")("c" . "C")("d" . "D")("e" . "E")("f" . "F")("g" . "G")
    ("h" . "H")("i" . "I")("j" . "J")("k" . "K")("l" . "L")("m" . "M")("n" . "N")
    ("o" . "O")("p" . "P")("q" . "Q")("r" . "R")("s" . "S")("t" . "T")("u" . "U")
    ("v" . "V")("w" . "W")("x" . "X")("y" . "Y")("z" . "Z")
    ("1" . "!")("2" . "@")("3" . "#")("4" . "$")("5" . "%")("6" . "^")("7" . "&")
    ("8" . "*")("9" . "(")("0" . ")")
    ("`" . "~")("[" . "{")("]" . "}")("-" . "_")("=" . "+")("," . "<")("." . ">")
    ("/" . "?")(";" . ":")("'" . "\"")("\\" . "|")
    ))

(defvar *sticky-list-jis*
  '(("a" . "A")("b" . "B")("c" . "C")("d" . "D")("e" . "E")("f" . "F")("g" . "G")
    ("h" . "H")("i" . "I")("j" . "J")("k" . "K")("l" . "L")("m" . "M")("n" . "N")
    ("o" . "O")("p" . "P")("q" . "Q")("r" . "R")("s" . "S")("t" . "T")("u" . "U")
    ("v" . "V")("w" . "W")("x" . "X")("y" . "Y")("z" . "Z")
    ("1" . "!")("2" . "\"")("3" . "#")("4" . "$")("5" . "%")("6" . "&")("7" . "'")
    ("8" . "(")("9" . ")")
    ("-" . "=")("^" . "~")("\\" . "|")("@" . "`")("[" . "{")(";" . "+")(":" . "*")
    ("]" . "}")("," . "<")("." . ">")("/" . "?")("\\" . "_")
    ))

(defvar *sticky-key* #\;)
(defvar *sticky-list* *sticky-list-ascii*)
(defvar *sticky-mode-map* nil)
(defvar *sticky-mode-sub-map* nil)

(defun set-sticky ()
  (sticky-mode (not (get-ime-mode))))

(add-hook '*ime-mode-hook* #'set-sticky)

(defvar-local *sticky-mode* nil)

(defun sticky-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*sticky-mode* arg sv)
  (update-mode-line t)
  (unless *sticky-mode-sub-map*
    (let ((skk-map (copy-keymap skk-map))
	  (skk-abbrev-map (copy-keymap skk-abbrev-map))
	  (skk-zenkaku-map (copy-keymap skk-zenkaku-map))
	  (sticky-map (make-sparse-keymap)))
      (mapcar #'(lambda (pair)
		  (define-key sticky-map
			      (character (cdr pair))
			      (lambda (&optional (arg 1))
				(interactive "*p")
				(let ((*last-command-char* (character (cdr pair))))
				  (self-insert-command)))))
	      (append *sticky-list* (list (cons *sticky-key* *sticky-key*))))
      (setq *sticky-mode-sub-map* (make-sparse-keymap))
      (mapcar #'(lambda (pair)
		  (define-key *sticky-mode-sub-map*
			      (character (first pair))
			      (lambda (&optional (arg 1))
				(interactive "*p")
				(let ((*last-command-char* (character (cdr pair))))
				  (call-interactively
				   (lookup-keymap
				    (cond
				     (j-mode  skk-map)
				     (j-abbrev skk-abbrev-map)
				     (j-zenkaku skk-zenkaku-map)
				     (t sticky-map))
				    (character (cdr pair))))))))
	      *sticky-list*)
      (define-key *sticky-mode-sub-map* *sticky-key*
		  #'(lambda (&optional (arg 1))
		      (interactive "*p")
		      (let ((*last-command-char* *sticky-key*))
			(call-interactively
			 (lookup-keymap
			  (cond
			   (j-mode  skk-map)
			   (j-abbrev skk-abbrev-map)
			   (j-zenkaku skk-zenkaku-map)
			   (t sticky-map))
			  *sticky-key*)))))
      (setf (symbol-function 'sticky-sub-map-prefix) *sticky-mode-sub-map*)))
  (unless *sticky-mode-map*
    (setq *sticky-mode-map* (make-sparse-keymap))
    (define-key *sticky-mode-map* *sticky-key* 'sticky-sub-map-prefix))
  (if *sticky-mode*
      (set-minor-mode-map *sticky-mode-map*)
    (unset-minor-mode-map *sticky-mode-map*))
  t)

(pushnew '(*sticky-mode* . "SkkStcy") *minor-mode-alist* :key #'car)

(provide "skk/skk-sticky")
