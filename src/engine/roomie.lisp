(in-package #:cloud)

;; hrtfearly > hrtfreverb
;; hrtfearly >
;; TODO: define listener globals
;; TODO: amp?

(defparameter *roomie-instr*
  "gamain init 0
   gimfp, gilowrt60, gihighrt60 init 0
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

(defparameter *roomie-instr-custom*
  "gamain init 0
   gimfp, gilowrt60, gihighrt60 init 0
   instr ~d
     klx, kly, klz, klrot, kx, ky, kz, kamp init 0
     klx   chnget  \"lisx\"
     kly   chnget  \"lisy\"
     klz   chnget  \"lisz\"
     klrot chnget  \"lisrot\"
     kx    chnget  \"srcx~d\"
     ky    chnget  \"srcy~d\"
     kz    chnget  \"srcz~d\"
     kamp  chnget  \"amplitud~d\"
     kSrcx port    kx, .025
     kSrcy port    ky, .025
     kSrcz port    kz, .025
     asig  diskin2 ~s, p4, p5, p6, 0, 32
     gamain = asig + gamain
     aleft, aright, gilowrt60, gihighrt60, gimfp hrtfearly asig, kSrcx, kSrcy, kSrcz, klx, kly, klz, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", 0, 8, 44100, ~d, 1, klrot, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f, ~f
           outs      aleft * p7, aright * p7
   endin")
;;     aleft, aright, irt60low, irt60high, imfp hrtfearly asig, kSrcx, kSrcy, kSrcz, gklisxSmooth, gklisySmooth, gkliszSmooth, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", ~d
(defclass roomie (audio roomie-room)
  ((pos :initarg :pos
        :Accessor pos
        :initform (v! 0 0 0)
        :documentation "3d position"))
  (:documentation "room based sound effect"))

(defun make-roomie (filename)
  (make-instance 'roomie :filename filename :room-type :small))

(defmethod initialize-instance :after ((obj roomie) &key filename room-type room-size)
  (let ((n (ninstr obj)))
    (setf (instr obj)
          (case room-type
            (:custom (format nil *roomie-instr-custom* n n n n n filename
                             (slot-value obj 'order)
                             (x room-size)
                             (y room-size)
                             (z room-size)
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
                             (slot-value obj 'ceil-gain3)))
            (t (format nil *roomie-instr* n n n n n filename (room-type obj)))))
    (init-channel (format nil "srcx~d" n) 0f0)
    (init-channel (format nil "srcy~d" n) 0f0)
    (init-channel (format nil "srcz~d" n) 0f0)))

(defmethod (setf pos) :before (new-value (obj roomie))
  (when (not (v3:= new-value (slot-value obj 'pos)))
    (let ((hsize (v3:*s (room-size obj) .5))
          (n (ninstr obj)))
      (set-channel (format nil "srcx~d" n) (+ (x new-value) (x hsize)))
      (set-channel (format nil "srcy~d" n) (+ (y new-value) (y hsize)))
      (set-channel (format nil "srcz~d" n) (+ (z new-value) (z hsize))))))

(defun upload-source (source)
  (let ((lpos  (get-listener-pos))
        (hsize (v3:*s (room-size source) 0.5)))
    (set-channel "lisx"   (+ (x lpos) (x hsize)))
    (set-channel "lisy"   (+ (y lpos) (y hsize)))
    (set-channel "lisz"   (+ (z lpos) (z hsize)))
    (set-channel "lisrot" (rot-y (get-listener-rot)))))
