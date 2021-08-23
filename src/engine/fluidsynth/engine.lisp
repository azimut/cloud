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
  ((sf2 :reader sf2 :initarg :sf2 :documentation "path to font"))
  (:default-initargs
   :sf2 (error ".SF2 path not provided")))

(defmethod initialize-instance :before ((obj engine) &key sf2)
  (assert (and (uiop:file-exists-p sf2) (str:ends-with-p ".sf2" sf2))))
(defmethod initialize-instance :after ((obj engine) &key)
  (schedule *server* (ninstr obj) 0 -1))

(defmethod formatit ((obj engine))
  (with-slots ((n ninstr) (s sf2)) obj
    (format nil *fluid-engine* n n s n n n n)))

(defun make-engine (sf2)
  (make-instance 'engine :sf2 sf2))
