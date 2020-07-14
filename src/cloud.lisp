(in-package #:cloud)

(defclass csound ()
  ())

(defclass orc ()
  ((name    :initarg :name)
   (globals :initarg :globals :reader globals
            :documentation "global variables string")
   (orc     :initarg :orc :reader orc
            :documentation "orchestra string, has the instruments definitions")
   (sco     :initarg :sco :reader sco
            :documentation "score string, has the wavetables")
   (file    :initarg :file)))

(defclass csound-server ()
  ((thread)
   (server)))

(defvar *c* nil)

(defvar *csound-globals*
  ";; Initialize the global variables.
   sr = 44100
   kr = 4410
   ksmps = 10
   nchnls = 2")

;; JACK?
;;(defvar *csound-options* '("-odac" "--nchnls=2" "-+rtaudio=jack" "-b128" "-B1048" "--sample-rate=44100"))
(defvar *csound-options* '("-odac" "-m3" "--nchnls=2"))

(defvar *orcs* (make-hash-table))
(defvar *default-csound-path* (asdf:system-relative-pathname :cloud "default-instruments/"))
(defvar *tmporc* NIL)
(defvar *tmppartialorc* NIL)
(defvar *thread* NIL)


(defun stich (&rest rest)
  "takes either several arguments or a list, puts them together
   in a string separated by new lines"
  (format nil "~{~%~a~%~}"
          (alexandria:flatten (remove-if #'null rest))))

(defun resolve-csound-path (key-name &optional (extension ".orc")
                                               (filepath *default-csound-path*))
  "returns the path"
  (let* ((name (symbol-name key-name))
         (file (merge-pathnames
                (str:concat name extension) filepath)))
    (or (probe-file file)
        (error "file missing"))))
