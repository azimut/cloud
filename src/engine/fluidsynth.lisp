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
(defparameter *fluid-roomie-engine*"
gamain init 0
gimfp, gilowrt60, gihighrt60 init 0

gklisxSmooth, gklisySmooth, gkliszSmooth, gklisdirSmooth init 0

giengine~d fluidEngine
gisfnum~d  fluidLoad   ~s, giengine~d, 1

instr ~d
  imvol init 7
  ibcount active ~d
  if (ibcount == 1) then
    kx, ky, kz, kamp init 0
    kx    chnget  \"srcx~d\"
    ky    chnget  \"srcy~d\"
    kz    chnget  \"srcz~d\"
    kamp  chnget  \"amplitud~d\"
    kSrcx port    kx, .025
    kSrcy port    ky, .025
    kSrcz port    kz, .025

    asig, asignull fluidOut giengine~d

    gamain = asig * imvol + gamain
    aleft, aright, gilowrt60, gihighrt60, gimfp hrtfearly asig * imvol, kSrcx, kSrcy, kSrcz, gklisxSmooth, gklisySmooth, gkliszSmooth, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", 0, 8, 44100, ~d, 1, gklisdirSmooth, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f
         outs      aleft, aright
  else
    turnoff
  endif
endin")
(defclass roomie-engine (roomie engine) ())
(defmethod formatit ((obj roomie-engine))
  (with-slots ((n ninstr) (s sf2)) obj
    (format nil *fluid-roomie-engine* n n s n n n n n n n n
            (slot-value obj 'order)
            (x (room-size obj))
            (z (room-size obj))
            (y (room-size obj))
            (slot-value obj 'wall-high)
            (slot-value obj 'wall-low)
            (slot-value obj 'wall-gain1)
            (slot-value obj 'wall-gain2)
            (slot-value obj 'wall-gain3)
            (slot-value obj 'piso-high)
            (slot-value obj 'piso-low)
            (slot-value obj 'piso-gain1)
            (slot-value obj 'piso-gain2)
            (slot-value obj 'piso-gain3)
            (slot-value obj 'ceil-high)
            (slot-value obj 'ceil-low)
            (slot-value obj 'ceil-gain1)
            (slot-value obj 'ceil-gain2)
            (slot-value obj 'ceil-gain3))))
(defun make-roomie-engine (sf2 pos room-size)
  (make-instance 'roomie-engine :sf2 sf2 :pos pos
                                :room-type :custom :room-size room-size))
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

