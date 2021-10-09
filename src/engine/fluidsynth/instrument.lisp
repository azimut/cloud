(in-package #:cloud)

(defclass fluidsynth (instrument)
  ((program :initarg :program :accessor program :documentation "font program number")
   (bank    :initarg :bank    :accessor bank    :documentation "font bank number")
   (channel :initarg :channel :accessor channel)
   (engine  :initarg :engine  :reader   engine))
  (:default-initargs
   :engine (error "needs an engine to get IO"))
  (:documentation "creates a new intr that plays on the ENGINE in the given CHANNEL"))

(defparameter *fluid-instr* "
massign 1,~d
instr ~d
  mididefault   60, p3
  midinoteonkey p4, p5
  ikey init p4
  ivel init p5
  fluidNote giengine~d, ~d, ikey, ivel
endin")

(defmethod print-object ((obj fluidsynth) stream)
  (print-unreadable-object (obj stream :type T :identity T)
    (with-slots (program bank channel) obj
      (format stream "PROGRAM:~a CHAN:~a BANK:~a" program channel bank))))

(defmethod program-select ((obj fluidsynth))
  (with-slots (engine bank channel program) obj
    (with-slots (ninstr) engine
      (send *server* (format nil "fluidProgramSelect giengine~d, ~d, gisfnum~d, ~d, ~d"
                             ninstr channel ninstr bank program)))))

(defmethod (setf channel) :after (_ (obj fluidsynth)) (program-select obj))
(defmethod (setf program) :after (_ (obj fluidsynth)) (program-select obj))
(defmethod (setf bank)    :after (_ (obj fluidsynth)) (program-select obj))

(defmethod initialize-instance :before ((obj fluidsynth) &key engine channel bank program)
  (check-type engine  engine)
  (check-type channel integer)
  (check-type program integer)
  (check-type bank    integer))

(defmethod initialize-instance :after ((obj fluidsynth) &key)
  (program-select obj))

(defmethod formatit ((obj fluidsynth))
  (with-slots (engine bank program channel) obj
    (format nil *fluid-instr* (ninstr obj) (ninstr obj) (ninstr engine) channel)))

(defun make-fluidsynth (engine &optional (channel 1) (bank 0) (program 0))
  (make-instance 'fluidsynth :engine engine :channel channel :bank bank :program program))
