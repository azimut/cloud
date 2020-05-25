;;;; cloud.asd

(asdf:defsystem #:cloud
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :depends-on (#:alexandria
               #:cl-arrows
               #:cl-ppcre
               #:csound
               #:serapeum
               #:str)
  :components ((:file "package")
               (:file "cloud")
               (:file "parser")
               (:file "merger")
               (:file "server")
               (:file "queries")
               (:file "player")
               (:file "default-instruments")))

(asdf:defsystem #:cloud/scheduler
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :depends-on (#:cloud
               #:scheduler)
  :components ((:file "scheduler")))

(asdf:defsystem #:cloud/engine
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src/engine"
  :depends-on (#:cloud
               #:rtg-math)
  :components ((:file "package")
               (:file "main")
               (:file "music")
               (:file "roomless")
               (:file "roomie")))
