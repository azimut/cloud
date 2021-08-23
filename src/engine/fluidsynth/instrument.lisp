(in-package #:cloud)

(defclass fluidsynth (audio)
  ((program :type integer :initarg :program :reader program :documentation "font program number")
   (bank    :type integer :initarg :bank    :reader bank    :documentation "font bank number")
   (channel :type integer :initarg :channel :reader channel)
   (engine  :type engine  :initarg :engine  :reader engine))
  (:default-initargs
   :engine (error "needs an engine to get IO"))
  (:documentation "creates a new intr that plays on the ENGINE in the given CHANNEL"))

(defparameter *fluid-instr* "
fluidProgramSelect giengine~d, ~d, gisfnum~d, ~d, ~d
massign 1,~d
instr ~d
  mididefault   60, p3
  midinoteonkey p4, p5
  ikey init p4
  ivel init p5
  fluidNote giengine~d, ~d, ikey, ivel
endin")

(defmethod initialize-instance :before ((obj fluidsynth) &key engine channel bank program)
  (check-type engine  engine)
  (check-type channel integer)
  (check-type program integer)
  (check-type bank    integer))

(defmethod formatit ((obj fluidsynth))
  (with-slots (engine bank program channel) obj
    (format nil *fluid-instr*
            (ninstr engine) channel (ninstr engine) bank program
            (ninstr obj) (ninstr obj) (ninstr engine) channel)))

(defun make-fluidsynth (engine &optional (channel 1) (bank 0) (program 0))
  (make-instance 'fluidsynth :engine engine :channel channel :bank bank :program program))


