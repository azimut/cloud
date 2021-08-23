(in-package #:cloud)

(defparameter *fluid-roomless-engine* "
giengine~d fluidEngine
gisfnum~d  fluidLoad   ~s, giengine~d, 1

instr ~d
  imvol init 10
  ibcount active ~d
  if (ibcount == 1) then
     kAz           chnget    \"azimut~d\"
     kElev         chnget    \"altitude~d\"
     kAmp          chnget    \"amplitude~d\"

    asig, asignull fluidOut giengine~d

     aleft, aright hrtfmove2 (asig * imvol * kAmp), kAz, kElev, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\"
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
