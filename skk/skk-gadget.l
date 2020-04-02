;;; skk-gadget.l

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

(defmacro make-string (len chr)
  (let ((tmp (gensym)))
    `(let ((,tmp ',chr))
       (make-sequence 'string ,len
		      :initial-element (if (numberp ,tmp)
					   (code-char ,tmp)
					 (character (substring (symbol-name ,tmp) -1)))))))

(defun current-time-string (&optional utime)
  (format-date-string "%a %b %d %H:%M:%S %Y" utime))

(defun pwd ()
  (concat "Directory " (default-directory)))

;todayはどしよかな

(defun skk-current-date (&optional f)
  (if f
      (funcall f (get-universal-time) nil nil nil)
    ""))

(defun skk-default-current-date (date-information format num-type gengo gengo-i m-al-i dow-al-i &optional and-time)
  (let ((year (j-num-exp (format-date-string
			    (if gengo (if (zerop gengo-i) "%g%e" "%G%e") "%Y") date-information) num-type))
	(month (j-num-exp (format-date-string
			   (if m-al-i (nth m-al-i '("%b" "%B" "%m")) "%b")) num-type))
	(day (j-num-exp (format-date-string "%d" date-information) num-type))
	(day-of-week (format-date-string "%a" date-information))
	(hour (j-num-exp (format-date-string "%H" date-information) num-type))
	(minute (j-num-exp (format-date-string "%M" date-information) num-type))
	(second (j-num-exp (format-date-string "%S" date-information) num-type)))
    (if and-time
	(format nil (substitute-string(or format "%s年%s月%s日(%s)%s時%s分%s秒") "%s" "~A")
		year month day day-of-week hour minute second)
      (format nil (substitute-string (or format "%s年%s月%s日(%s)") "%s" "~A")
	      year month day day-of-week))))

;unit

(defun skk-gengo-to-ad (&optional head tail)
  ;; 元号を西暦に変換する。オプション引数の HEAD, TAIL が指定されてい
  ;; れば、その文字列を先頭、末尾に連結する。
  ;; 辞書見出し例;
  ;;   しょうわ#ねん /(skk-gengo-to-ad "" "年")/(skk-gengo-to-ad "" " 年")/\
  ;;   (skk-gengo-to-ad "西暦" "年")/(skk-gengo-to-ad "西暦" " 年")/
  (let ((m (match-data)))
    (unwind-protect
	(when (string-match (car j-num-list)
			    j-henkan-key)
	  (let ((v (skk-gengo-to-ad-1
		    (substring j-henkan-key 0 (match-beginning 0))
		    (read-from-string (car j-num-list)))))
	    (when v
	      (format nil "~A~D~A" head v tail))))
      (store-match-data m))))

(defun skk-gengo-to-ad-1 (gengo number)
  ;; GENGO is a string and NUMBER is a number.
  ;; return a year (number) equal to GENGO-NUMBER.
  (+ number
     (cond
      ((eq number 0)
       (skk-error "0 年はあり得ない"
		  "Cannot convert 0 year"))
      ((member gengo '("へいせい" "平成") :test 'equal)
       1988)
      ((member gengo '("しょうわ" "昭和") :test 'equal)
       (if (> 64 number)
	   1925
	 (skk-error "昭和は 63 年までです"
		"The last year of Showa is 63")))
      ((member gengo '("たいしょう" "大正") :test 'equal)
       (if (> 15 number)
	   1911
	 (skk-error "大正は 14 年までです"
		    "The last year of Taisyo is 14")))
      ((member gengo '("めいじ" "明治") :test 'equal)
       (if (> 45 number)
	   1867
	 (skk-error "明治は 44 年までです"
		    "The last year of Meiji is 44")))
      (t
       (skk-error "判別不能な元号です！"
		  "Unknown Gengo!")))))

(defun skk-ad-to-gengo (gengo-index &optional divider tail not-gannen)
  ;; 西暦を元号に変換する。オプション引数の divider が指定されていれば、年号と
  ;; 数字の間に、tail が指定されていれば、数字の末尾に、それぞれの文字列を連結
  ;; する。
  ;; 辞書見出し例;
  ;; せいれき#ねん /(skk-ad-to-gengo 0 nil "年")/(skk-ad-to-gengo 0 " " " 年")/
  (let ((date  (encode-universal-time 1 1 1 1 1 (read-from-string (car j-num-list)))))
    (concat (format-date-string (if (zerop gengo-index) "%g" "%G") date)
	    divider
	    (format-date-string (if not-gannen "%E" "%e") date)
	    tail)))

(defun skk-calc (operator)
  ;; 2 つの引数を取って operator の計算をする。
  ;; 注意: '/ は引数として渡せないので (defalias 'div '/) などとし、別の形で
  ;; skk-calc に渡す。
  ;; 辞書見出し例; #*# /(skk-calc '*)/
  (format nil "~D" (apply operator
			   (mapcar 'read-from-string
				   j-num-list))))

(defvar *skk-units-alist*
  '(("mile" ("km" . 1.6093) ("yard" . 1760))
    ("yard" ("feet" . 3) ("cm" . 91.44))
    ("feet" ("inch" . 12) ("cm" . 30.48))
    ("inch" ("feet" . 0.5) ("cm" . 2.54))))

(defmacro skk-gadget-units-conversion (unit-from number unit-to)
  (let ((unit-from unit-from)
	(unit-to unit-to)
	(number (read-from-string (car j-num-list))))
    `(let ((v (assoc ,unit-to
		     (cdr (assoc ,unit-from *skk-units-alist* :test 'equal)) :test 'equal)))
       (when v
	 (concat (format nil "~A" (* ,number (cdr v)))
		 (car v))))))

;;;###autoload
(defun skk-plus ()
  ;; 辞書見出し例; #+#+# /(skk-plus)/
  (skk-calc '+))

;;;###autoload
(defun skk-minus ()
  (skk-calc '-))

;;;###autoload
(defun skk-times ()
  (skk-calc '*))


;;やるきの欠片も見えねぇ
(defun skk-error (jp en)
  (error jp))

(provide "skk/skk-gadget")
