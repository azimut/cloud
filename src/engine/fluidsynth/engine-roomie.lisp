(in-package #:cloud)

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

