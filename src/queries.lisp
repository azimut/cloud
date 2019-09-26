(in-package #:cloud)

(defun list-orcs ()
  (alexandria:hash-table-keys *orcs*))

(defun get-orc (orc-name &key n-instr (filepath *default-csound-path*))
  "returns the orc string"
  (assert (keywordp orc-name))
  (with-slots (orc) (gethash orc-name *orcs*)
    (let ((orchestra (or orc
                         (alexandria:read-file-into-string
                          (resolve-csound-path orc-name ".orc" filepath)))))
      (if n-instr
          (nth n-instr (get-instr orchestra))
          orchestra))))

(defun get-sco (sco-name &key (filepath *default-csound-path*))
  "returns the score string"
  (assert (keywordp sco-name))
  (with-slots (sco) (gethash sco-name *orcs*)
    (or sco
        (alexandria:read-file-into-string
         (resolve-csound-path sco-name ".sco" filepath)))))

(defun get-globals (orc-name &optional filter-globals)
  "returns the string with the global definitions"
  (assert (keywordp orc-name))
  (with-slots (globals) (gethash orc-name *orcs*)
    (if filter-globals
        (loop :for default :in '("sr" "kr" "ksmps" "nchnls")
              :finally (return result)
              :with result := globals
              :do (setf result (cl-ppcre:regex-replace-all
                                (format nil "\\s*~a\\s*=\\s*.*\\n" default)
                                result (format nil "~%"))))
        globals)))

(defun get-orchestra (orc-name &optional n-instr)
  "returns an orchestra object"
  (assert (keywordp orc-name))
  (if n-instr
      (setf *tmppartialorc*
            (make-instance 'orc
                           :sco (get-sco orc-name)
                           :orc (get-orc orc-name :n-instr n-instr)
                           :globals (get-globals orc-name)
                           :name "slice"))
      (gethash orc-name *orcs*)))
