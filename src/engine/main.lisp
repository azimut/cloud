(in-package #:cloud)

(defvar *file-to-instrument* (make-hash-table :test #'equal))
(defvar *instruments* 0)
;; TODO: restart?
(defun ninstr-p (filename)
  (and (gethash filename *file-to-instrument*)
       t))
(defun next-instrument (filename)
  (setf (gethash filename *file-to-instrument*)
        (or (gethash filename *file-to-instrument*)
            (incf *instruments*))))
(defun reset-instruments ()
  (clrhash *file-to-instrument*)
  (setf *instruments* 0))

(defclass audio ()
  ((filename :initarg :filename
             :reader   filename
             :documentation "location on disk")
   (instr    :accessor instr
             :documentation "csound instr string")
   (ninstr   :reader   ninstr
             :documentation "csound instrument number"))
  (:default-initargs
   :filename (error ":filename must be specified"))
  (:documentation "base audio class"))

(defmethod initialize-instance :before ((obj audio) &key filename)
  (assert (probe-file filename)))
(defmethod initialize-instance :after ((obj audio) &key filename)
  (setf (slot-value obj 'ninstr) (next-instrument filename)))

(defmethod (setf instr) :after (new-value (obj audio))
  (send *server* new-value))

(defun channel-string (name n)
  (format nil "~a~d" name n))
(defun set-channel (name value)
  (chnset *server* name value))
(defun init-channel (name default-value)
  (send *server* (format nil "chn_k ~s, 2" name))
  (set-channel name default-value))

(defun get-listener-pos () (v! 0 0 0))
(defun get-listener-rot () (q! 0f0 0f0 0f0 0f0))
