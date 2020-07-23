(in-package #:cloud)

(defvar *instruments* 0)

(defun next-instrument ()
  (incf *instruments*))
(defun reset-instruments ()
  (setf *instruments* 0))

(defclass audio ()
  ((filename :initarg :filename
             :initform nil
             :reader filename
             :documentation "location on disk")
   (instr    :accessor instr :type string  :documentation "csound effective instrument")
   (ninstr   :reader  ninstr :type integer :documentation "csound instrument number"))
  (:documentation "base audio class"))

(defmethod free ((obj audio))
  (let ((msg (format nil "remove ~d" (ninstr obj))))
    (send *server* msg)))

(defgeneric formatit (obj)
  (:method (obj) ""))

(defmethod initialize-instance :before ((obj audio) &key filename)
  (assert (or (not filename) (probe-file filename)))
  (assert (or (not filename) (str:ends-with-p "wav" filename))))
(defmethod initialize-instance :after ((obj audio) &key)
  (setf (slot-value obj 'ninstr) (next-instrument))
  (setf (instr obj) (formatit obj)))

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
