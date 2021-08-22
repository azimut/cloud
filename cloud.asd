;;;; cloud.asd

(asdf:defsystem #:cloud
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :depends-on (#:alexandria
               #:arrows
               #:cl-ppcre
               #:csound
               #:parse-float
               #:serapeum
               #:str)
  :components ((:file "package")
               (:file "cloud")
               (:file "parser")
               (:file "merger")
               (:file "internal")
               (:file "queries")
               (:file "player")
               (:file "default-instruments")))

(asdf:defsystem #:cloud/udp
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :depends-on (#:cloud
               #:usocket)
  :components ((:file "udp")))

(asdf:defsystem #:cloud/engine
  :description "Describe cloud here"
  :author "azimut <azimut.github@protonmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src/engine"
  :depends-on (#:cloud/udp
               #:rtg-math)
  :components ((:file "package")
               (:file "main")
               (:file "music")
               (:file "roomless")
               (:file "roomie-room")
               (:file "roomie-listener")
               (:file "roomie")
               (:file "fluidsynth")))
