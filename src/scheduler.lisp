(in-package #:cloud)

;; Run this after (start-csound)
;;(scheduler:sched-run *scheduler*)

(defvar *scheduler* (make-instance 'scheduler:scheduler))

(defmacro at (time function &rest arguments)
  `(scheduler:sched-add *scheduler*
                        (+ ,time (scheduler:sched-time *scheduler*))
                        ,function ,@arguments))

(declaim (inline now))
(defun now ()
  (scheduler:sched-time *scheduler*))
