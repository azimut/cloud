(in-package #:cloud)

(defclass music (audio)
  ()
  (:documentation "background music, positionless"))

(defvar *music-instr*
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

(defmethod formatit ((obj music))
  (let ((n (ninstr obj)))
    (format nil *music-instr* n n (filename obj))))

(defmethod initialize-instance :after ((obj music) &key)
  (setf (instr obj) (formatit obj)))

(defun make-music (filename)
  (make-instance 'music :filename filename))

;; (make-music "/home/sendai/quicklisp/local-projects/aubio/static/loop_amen.wav")
;; (make-play amen "i1" :rate 1 :skip 0 :wrap 1 :amp 1)
;; (play-amen 3)
