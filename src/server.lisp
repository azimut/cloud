(in-package #:cloud)

(defun set-csound-options (&optional (options *csound-options*))
  "sends list of options to csound server, only happens once before started"
  (declare (type list options))
  (loop :for option :in options
        :when (stringp option)
        :do (csound:csoundsetoption *c* option)))

;; TODO: ew
(defun start-csound (orchestra)
  (declare (type orc orchestra))
  ;;(scheduler:sched-run *scheduler*)
  (with-slots (name orc sco globals) orchestra
    (let ((server-up-p *c*))
      (unless server-up-p
        ;; Set headless flags
        (csound:csoundinitialize 3)
        (setf *c* (csound:csoundcreate (cffi:null-pointer)))
        (set-csound-options *csound-options*))
      (csound:csoundstart *c*)
      ;; Initialize ORC
      (csound:csoundcompileorc
       *c*
       (print (stich *csound-globals* globals orc)))
      ;; GOGOGO!
      ;; Init fN wave tables for this ORC
      (csound:csoundreadscore *c* (print sco)))))

(defun load-csound (orchestra)
  "one can load sco and orc without stop the perfomance thread
   or restart the server"
  (declare (type orc orchestra))
  (with-slots (orc sco globals) orchestra
    ;; Initialize ORC
    (csound:csoundcompileorc *c* (stich globals orc))
    ;; Init fN wave tables for this ORC
    (csound:csoundreadscore *c* sco)))

(defun start-thread ()
  (setf *thread*
        (bt:make-thread
         (lambda ()
           (loop :for frame = (csound:csoundperformksmps *c*)
                 :while (= frame 0))))))

(defun stop-thread ()
  (bt:destroy-thread *thread*))
