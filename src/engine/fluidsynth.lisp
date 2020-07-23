(in-package #:cloud)

(defparameter *fluid-engine* "
giengine~d fluidEngine
gisfnum~d  fluidLoad   ~s, giengine~d, 1

instr ~d
  imvol init 7
  ibcount active ~d
  if (ibcount == 1) then
    asigl, asigr fluidOut giengine~d
                 outs     asigl*imvol, asigr*imvol
   else
     turnoff
   endif
endin")

;; inherith from audio?
(defclass engine (audio)
  ((sf2 :type string  :reader sf2 :initarg :sf2 :documentation "path to font")))

(defmethod initialize-instance :before ((obj engine) &key sf2)
  (assert (and (uiop:file-exists-p sf2) (str:ends-with-p ".sf2" sf2))))
(defmethod initialize-instance :after ((obj engine) &key)
  (schedule *server* (ninstr obj) 0 -1))

(defmethod formatit ((obj engine))
  (with-slots ((n ninstr) (s sf2)) obj
    (format nil *fluid-engine* n n s n n n n)))

(defun make-engine (sf2)
  (make-instance 'engine :sf2 sf2))

;;--------------------------------------------------
(defparameter *fluid-roomless-engine* "
giengine~d fluidEngine
gisfnum~d  fluidLoad   ~s, giengine~d, 1

instr ~d
  imvol init 7
  ibcount active ~d
  if (ibcount == 1) then
     kAz           chnget    \"azimut~d\"
     kElev         chnget    \"altitude~d\"
     kAmp          chnget    \"amplitude~d\"

    asig, asignull fluidOut giengine~d

     aleft, aright hrtfmove2 (asig * imvol * kAmp), kAz, kElev, \"/home/sendai/quicklisp/local-projects/cloud/hrtf-44100-left.dat\", \"/home/sendai/quicklisp/local-projects/cloud/hrtf-44100-right.dat\"
            outs        aleft, aright

   else
     turnoff
   endif
endin")
(defclass roomless-engine (roomless engine) ())
(defmethod formatit ((obj roomless-engine))
  (with-slots ((n ninstr) (s sf2)) obj
    (format nil *fluid-roomless-engine* n n s n n n n n n n)))
(defun make-roomless-engine (sf2 pos)
  (make-instance 'roomless-engine :sf2 sf2 :pos pos))
;;--------------------------------------------------
(defclass roomie-engine (roomie engine) ())
;;--------------------------------------------------
(defclass fluidsynth (audio)
  ((program :type integer :initarg :program :reader program :documentation "font program number")
   (bank    :type integer :initarg :bank    :reader bank    :documentation "font bank number")
   (engine  :type engine  :initarg :engine  :reader engine)
   (channel :type integer :initarg :channel :reader channel))
  (:default-initargs
   :engine (error "needs an engine to get IO")
   :channel 1
   :bank 0
   :program 0))

(defparameter *fluid-instr* "
fluidProgramSelect giengine~d, ~d, gisfnum~d, ~d, ~d

instr ~d
  ikey init p4
  ivel init p5
  fluidNote giengine~d, ~d, ikey, ivel
endin")

(defmethod initialize-instance :before ((obj fluidsynth) &key engine channel bank program)
  (check-type program integer)
  (check-type bank    integer)
  (check-type channel integer)
  (check-type engine  engine))

(defmethod formatit ((obj fluidsynth))
  (with-slots (engine bank program channel) obj
    (format nil *fluid-instr*
            (ninstr engine) channel (ninstr engine) bank program
            (ninstr obj) (ninstr engine) channel)))

(defun make-fluidsynth (engine &optional channel bank program)
  (make-instance 'fluidsynth :engine engine :channel channel :bank bank :program program))

