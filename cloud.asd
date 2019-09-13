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
               (:file "cloud")))
