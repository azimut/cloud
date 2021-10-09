(in-package #:cloud)

(defclass engine (instrument)
  ((sf2 :initform (error ".SF2 path not provided") :reader sf2 :initarg :sf2)))

(defparameter *fluid-engine* "
   giengine~d fluidEngine
   gisfnum~d  fluidLoad   ~s, giengine~d, 1
   instr ~d
     imvol   init 7
     ibcount active ~d
     if (ibcount == 1) then
       asigl, asigr fluidOut giengine~d
                    outs     asigl*imvol, asigr*imvol
      else
        turnoff
      endif
   endin"
  "fluidOut => outs")

(defmethod initialize-instance :before ((obj engine) &key sf2)
  (assert (uiop:file-exists-p sf2))
  (assert (str:ends-with-p ".sf2" (str:downcase sf2))))
(defmethod initialize-instance :after ((obj engine) &key)
  (schedule *server* (ninstr obj) 0 -1))

(defmethod formatit ((obj engine))
  (with-slots ((n ninstr) (s sf2)) obj
    (format nil *fluid-engine* n n s n n n n)))

(defun make-engine (sf2)
  (make-instance 'engine :sf2 sf2))
