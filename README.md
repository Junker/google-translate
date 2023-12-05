# Google-Translate

Free Google Translate API for Common Lisp

## Installation

This system can be installed from [UltraLisp](https://ultralisp.org/) like this:

```common-lisp
(ql-dist:install-dist "http://dist.ultralisp.org/"
                      :prompt nil)
(ql:quickload "google-translate")
```

## Usage

```common-lisp
(multiple-value-bind (text data)
    (google-translate:translate "How are you?" :target "de"))
;; "Wie geht es dir?"
;;  (:TRANSLATION #(#("Wie geht es dir?" "How are you?" NULL NULL 10))
;;   :ALL-TRANSLATIONS #(#("interjection"
;;                         #("Wie geht es Ihnen?" "Wie geht es dir?" "Wie geht's Ihnen?"
;;                           "Wie geht's dir?")
;;                         #(#("Wie geht es Ihnen?"
;;                             #("How are you?" "How is it going?" "How are you getting along?") NULL
;;                             0.4437473d0)
;;                           #("Wie geht es dir?" #("How are you?") NULL 0.14633234d0)
;;                           #("Wie geht's Ihnen?" #("How are you?"))
;;                           #("Wie geht's dir?" #("How are you?")))
;;                         "How are you?" 9))
;;   :ORIGINAL-LANGUAGE "en"
;;   :POSSIBLE-TRANSLATIONS #(#("How are you?" NULL
;;                              #(#("Wie geht es dir?" 1000 T NIL #(10))
;;                                #("Wie geht es Ihnen?" 1000 T NIL #(1)) #("Wie gehts?" 1000 T NIL #(1))
;;                                #("Wie geht es?" 1000 T NIL #(1)) #("Wie gehts dir?" 1000 T NIL #(1)))
;;                              #(#(0 12)) "How are you?" 0 0))
;;   :CONFIDENCE 1
;;   :POSSIBLE-MISTAKES #()
;;   :LANGUAGE #(#("en") NULL #(1) #("en"))
;;   :SYNONYMS NIL
;;   :DEFINITIONS NIL
;;   :EXAMPLES NIL
;;   :SEE-ALSO NIL)

(google-translate:translate "How are you?"
                            :target "de"
                            :source "en"
                            :dex-args '(:keep-alive nil
                                        :connect-timeout 5
                                        :verbose t
                                        :proxy "https://example.org:8080"))
```

`dex-args` - dexador [request arguments](https://github.com/fukamachi/dexador#functions)
