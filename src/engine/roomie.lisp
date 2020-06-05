(in-package #:cloud)

;; hrtfearly > hrtfreverb
;; hrtfearly >

(defparameter *roomie-instr*
  "instr ~d
     kSrcx         chnget    \"srcx~d\"
     kSrcy         chnget    \"srcy~d\"
     kSrcz         chnget    \"srcz~d\"
     asig          diskin2   ~s, p4, p5, p6, 0, 32
     aleft, aright hrtfmove2 (asig * kAmp), kAz, kElev, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\"
                   outs      aleft * p7, aright * p7
   endin")

(defclass roomie (audio)
  ((pos :initarg :pos
        :initform (error ":pos must be specified")
        :accessor pos
        :documentation "3d position"))
  (:documentation "room based sound effect"))

(defun init-room ()
  (setup-channel "dstx" 999)
  (setup-channel "dsty" 999)
  (setup-channel "dstz" 999))

(defmethod initialize-instance :after ((obj roomie) &key)
  (let ((n (ninstr obj)))
    (setup-channel "srcx" n)
    (setup-channel "srcy" n)
    (setup-channel "srcz" n)))

(defmethod (setf pos) :after (value (obj roomie))
  (let ((n (ninstr obj)))
    (set-channel "srcx" n (x value))
    (set-channel "srcy" n (y value))
    (set-channel "srcz" n (z value))))

(defmethod update-listener ((obj roomie) listener-pos)
  (set-channel "dstx" 999 (x listener-pos))
  (set-channel "dsty" 999 (y listener-pos))
  (set-channel "dstz" 999 (z listener-pos)))
