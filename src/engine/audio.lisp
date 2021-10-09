(in-package #:cloud)

(defclass audio ()
  ((filename :initarg :filename
             :initform nil
             :reader filename
             :documentation "location on disk"))
  (:documentation "file audio class"))
(defmethod initialize-instance :before ((obj audio) &key filename)
  (assert (probe-file filename))
  (assert (str:ends-with-p "wav" filename)))
