(in-package #:cloud)

(defclass music (audio)
  ()
  (:documentation "background music, positionless"))

(defparameter *music-instr*
  "instr ~d
     ibcount active ~d
     if (ibcount == 1) then
       a1,a2 diskin2 ~s, p4, p5, p6, 0, 32
       aout  linseg  0, 2, p7
             outs    a1 * aout, a2 * aout
     else
       turnoff
     endif
   endin")

(defmethod initialize-instance :after ((obj music) &key filename)
  (let* ((n (ninstr obj))
         (i (format nil *music-instr* n n filename)))
    (setf (slot-value obj 'instr)  i)
    (csound:compile-orc *c* i)))

(defun make-music (filename)
  (make-instance 'music :filename filename))

;; (make-music "/home/sendai/quicklisp/local-projects/aubio/static/loop_amen.wav")
;; (make-play amen "i1" :rate 1 :skip 0 :wrap 1 :amp 1)
;; (play-amen 3)
