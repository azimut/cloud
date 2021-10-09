(in-package #:cloud)
(defun set-channel (name value)
  (chnset *server* name value))
(defun init-channel (name default-value)
  (send *server* (format nil "chn_k ~s, 2" name))
  (set-channel name default-value))

(defun hrtf-left ()
  (namestring
   (asdf:system-relative-pathname :cloud "static/hrtf-44100-left.dat")))

(defun hrtf-right ()
  (namestring
   (asdf:system-relative-pathname :cloud "static/hrtf-44100-right.dat")))

(defun get-listener-pos () (v! 0 0 0))
(defun get-listener-rot () (q! 0f0 0f0 0f0 0f0))
