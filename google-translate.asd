(defsystem "google-translate"
  :version "0.2.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :depends-on ("alexandria" "dexador" "quri" "jonathan")
  :description "Free Google Translate API"
  :homepage "https://github.com/Junker/google-translate"
  :source-control (:git "https://github.com/Junker/google-translate.git")
  :components ((:file "package")
               (:file "google-translate")))
