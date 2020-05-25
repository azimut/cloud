(in-package #:cloud)

(defun set-csound-options (&optional (options *csound-options*))
  "sends list of options to csound server, only happens once before started"
  (declare (type list options))
  (loop :for option :in options
        :when (stringp option)
        :do (csound:set-option *c* option)))

;; TODO: ew
(defun start-csound ()
  (let ((server-up-p *c*))
    (unless server-up-p
      ;; Set headless flags
      (csound:initialize 3)
      (setf *c* (csound:create (cffi:null-pointer)))
      (set-csound-options *csound-options*)
      (csound:start *c*)
      (start-thread))))

(defun load-csound (orchestra)
  "one can load sco and orc without stop the perfomance thread
   or restart the server"
  (declare (type orc orchestra))
  (with-slots (orc sco globals) orchestra
    ;; Initialize ORC
    (csound:compile-orc *c* (stich globals orc))
    ;; Init fN wave tables for this ORC
    (csound:read-score *c* (stich sco))))

(cffi:defcallback newthread :int ((data :pointer))
  (csound:perform data))

(defun start-thread ()
  (when *c*
    (csound:create-thread (cffi:get-callback 'newthread) *c*)))

(defun stop-csound ()
  (csound:stop *c*)
  (csound:destroy *c*))
