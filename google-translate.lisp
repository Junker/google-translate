(in-package #:google-translate)

(defconstant +tkk1+ 406398)
(defconstant +tkk2+ 2087938574)
(defparameter *url* "https://translate.google.com/translate_a/single")
(defparameter *user-agent* "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

(defvar *response-parts-name-mapping*
  '(:translation 0
    :all-translations 1
    :original-language 2
    :possible-translations 5
    :confidence 6
    :possible-mistakes 7
    :language 8
    :synonyms 11
    :definitions 12
    :examples 13
    :see-also 14))


(defun shr (x width bits)
  "Compute bitwise right shift of x by 'bits' bits, represented on 'width' bits"
  (logand (ash x (- bits))
          (1- (ash 1 width))))

(defun push-end (object place)
  (nconc place (list object)))


(defun rl (a b)
  (loop for c from 0 by 3
        while (< c (- (length b) 2))
        do
           (let* ((d (char b (+ c 2)))
                  (d (if (char>= d #\a)
                         (- (char-code d) 87)
                         (digit-char-p d)))
                  (d (if (char= (char b (1+ c)) #\+)
                         (shr a 31 d)
                         (ash a d))))
             (setf a (if (char= (char b c) #\+)
                         (logand (+ a d) 4294967295)
                         (logxor a d)))))
  a)


(defun generate-token (text)
  (let ((d (list nil)))
    (loop for f from 0
          while (< f (length text))
          do
             (let ((g (char-code (char text f))))
               (if (< g 128)
                   (push-end g d)
                   (progn
                     (if (< g 2048)
                         (push-end (logior (ash g -6) 192) d)
                         (progn
                           (if (and (eq (logand g 64512) 55296)
                                    (< (1+ f) (length text))
                                    (eq (logand (char-code (char text (1+ f))) 64512)
                                        56320))
                               (progn
                                 (setf g (+ 65536
                                            (ash (logand g 1023) 10)
                                            (logand (char-code (char text (decf f)))
                                                    1023)))
                                 (push-end (logior (ash g -18) 240) d)
                                 (push-end (logior (logand (ash g -12) 63) 128) d))
                               (progn
                                 (push-end (logior (ash g -12) 224) d)))
                           (push-end (logior (logand 6 63) 128) d)))
                     (push-end (logior (logand g 63) 128) d)))))
    (setf d (cdr d))
    (let ((a +tkk1+))
      (dolist (val d)
        (incf a val)
        (setf a (rl a "+-a^+6")))
      (setf a (rl a "+-3^+b+-f"))
      (setf a (logxor a +tkk2+))
      (when (< a 0)
        (setf a (+ (logand a 2147483647) 2147483648)))
      (setf a (mod a 1000000))
      (format nil "~A.~A" a (logxor a +tkk1+)))))

(defun build-query-params (text source target token)
  `(("client" . "gtx")
    ("hl" . "en")
    ("dt" . "at")
    ("dt" . "bd")
    ("dt" . "ex")
    ("dt" . "ld")
    ("dt" . "md")
    ("dt" . "qca")
    ("dt" . "rw")
    ("dt" . "rm")
    ("dt" . "ss")
    ("dt" . "t")
    ("sl" . ,source) ; Source language
    ("tl" . ,target) ; Target language
    ("q" . ,text) ; String to translate
    ("ie" . "UTF-8") ; Input encoding
    ("oe" . "UTF-8") ; Output encoding
    ("multires" . 1)
    ("otf" . 0)
    ("pc" . 1)
    ("trs" . 1)
    ("ssel" . 0)
    ("tsel" . 0)
    ("kc" . 1)
    ("tk" . ,token)))

(defun parse-extra-data (data)
  (loop for (name idx) on *response-parts-name-mapping* by #'cddr
        collect name
        collect (when (< idx (length data)) (svref data idx))))

;; PUBLIC
(defun translate (text &key (target "en") (source "auto") dex-args)
  (if (string= target source)
      text
      (let* ((qurl (quri:make-uri :defaults *url*
                                  :query (build-query-params text source target (generate-token text))))
             (response (apply #'dex:get qurl
                              :headers `(("User-Agent" . ,*user-agent*))
                              :keep-alive nil
                              dex-args))
             (response-arr (com.inuoe.jzon:parse response)))
        (values
         (reduce #'(lambda (carry item) (if (typep item 'string)
                                            (uiop:strcat carry item)
                                            carry))
                 (svref response-arr 0)
                 :key #'(lambda (a) (svref a 0)))
         (parse-extra-data response-arr)))))
