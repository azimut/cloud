(in-package #:cloud)

(defvar *instrument-index* 0)

(defclass instrument ()
  ((instr  :accessor instr  :documentation "csound effective instrument")
   (ninstr :reader   ninstr :documentation "csound instrument number"))
  (:documentation "csound base instrument class"))

(defmethod free :after ((obj instrument))
  (let ((msg (format nil "remove ~d" (ninstr obj))))
    (send *server* msg)))

(defmethod (setf instr) :after (new-value (obj instrument))
  (send *server* new-value))

(defun reset-instrument-counter () (setf *instrument-index* 0))
(defun current-instrument-counter () (incf *instrument-index*))

(defmethod initialize-instance :after ((obj instrument) &key)
  (setf (slot-value obj 'ninstr) (current-instrument-counter))
  (setf (instr obj) (formatit obj)))


