(in-package #:cloud)
;; hrtfearly > hrtfreverb
;; hrtfearly >
;; TODO: define listener globals
;; TODO: other room arguments for custom are missing
;; TODO: amp?
;; TODO: initial source listener position update?
;; custom room needs:
;; - listener rotation
;; x room-dim enforce 2ms MIN in all axis
;; hrtfreverb needs:
;; x reverb ammount (channel), which applies to a "delay" opcode (instr 10)
;; x an instr playing that "hrtfreverb" opcode
;; x input global of audio
;; x zero global audio

(defparameter *roomie-instr*
  "gamain init 0
   gimfp init 0
   gilowrt60, gihighrt60 init 0
   instr ~d
     klx, kly, klz, kx, ky, kz, kamp init 0
     klx   chnget  \"lisx\"
     kly   chnget  \"lisy\"
     klz   chnget  \"lisz\"
     kx    chnget  \"srcx~d\"
     ky    chnget  \"srcy~d\"
     kz    chnget  \"srcz~d\"
     kamp  chnget  \"amplitud~d\"
     kSrcx port    kx, .025
     kSrcy port    ky, .025
     kSrcz port    kz, .025
     asig  diskin2 ~s, p4, p5, p6, 0, 32
     gamain = asig + gamain
     aleft, aright, gilowrt60, gihighrt60, gimfp hrtfearly asig, kSrcx, kSrcy, kSrcz, klx, kly, klz, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", ~d
           outs      aleft * p7, aright * p7
   endin")
;;     aleft, aright, irt60low, irt60high, imfp hrtfearly asig, kSrcx, kSrcy, kSrcz, gklisxSmooth, gklisySmooth, gkliszSmooth, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", ~d
(defclass roomie (audio roomie-room)
  ((pos :initarg :pos
        :accessor pos
        :initform (v! 0 0 0)
        :documentation "3d position"))
  (:documentation "room based sound effect"))

(defun make-roomie (filename)
  (make-instance 'roomie :filename filename :room-type :small))

(defun format-roomie (n filename room-type)
  (format nil *roomie-instr* n n n n n filename room-type))

(defmethod initialize-instance :after ((obj roomie) &key filename)
  (let ((n (ninstr obj)))
    (setf (instr obj) (format-roomie n filename (room-type obj)))
    (send *server* (format nil "chn_k \"~a~d\", 2" "srcx" n))
    (send *server* (format nil "chn_k \"~a~d\", 2" "srcy" n))
    (send *server* (format nil "chn_k \"~a~d\", 2" "srcz" n))))

(defmethod (setf pos) :after (value (obj roomie))
  (let ((n (ninstr obj)))
    (set-channel "srcx" n (x value))
    (set-channel "srcy" n (y value))
    (set-channel "srcz" n (z value))))

(defun upload-listener ()
  (let ((new-pos (get-listener-pos)))
    (chnset *server* "lposx" (x new-pos))
    (chnset *server* "lposy" (y new-pos))
    (chnset *server* "lposz" (z new-pos))))

(defun upload-source (source)
  (let ((spos  (v! 1
                   0
                   .5) ;;(pos source)
               )
        (lpos  (v! 0 0 0) ;;(get-listener-pos)
               )
        (hsize (v3:*s (room-size source) 0.5)))
    (chnset *server* "lposx" (print (- (x lpos) (x hsize))))
    (chnset *server* "lposy" (print (- (y lpos) (y hsize))))
    (chnset *server* "lposz" (print (- (z lpos) (z hsize))))
    ;;
    (set-channel "srcpos" (ninstr source) (print (- (x spos) (x hsize))))
    (set-channel "srcpos" (ninstr source) (print (- (y spos) (y hsize))))
    (set-channel "srcpos" (ninstr source) (print (- (z spos) (z hsize))))))
