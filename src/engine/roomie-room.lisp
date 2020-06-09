(in-package #:cloud)

;; TODO: assumes 1(one) reverb at the time
;; TODO: schedule 1 instance
;; gamain     - gathers diskin2 audio
;; gimfp      - return value of hrtfearly, 5th and last
;; gilowrt60  - "
;; gihighrt60 - "
;; ~d, number of reflections, range 0-4, default 1
(defparameter *roomie-room*
  "instr 1010
     ibcount active 1010
     if (ibcount == 1) then
       kverb init 0
       kverb chnget \"reverb\"
       aL, aR, idel hrtfreverb gamain, gilowrt60, gihighrt60, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", 44100, gimfp, ~d
       alateL delay aL * kverb, idel
       alateR delay aR * kverb, idel
       outs alateL, alateR
       gamain = 0
     else
       turnoff
     endif
   endin"
  "hrtfreverb > outs")

(defclass roomie-room ()
  ((reverb    :accessor reverb
              :initarg :reverb
              :documentation "reverb fudge factor")
   (room-type :initarg :room-type
              :reader   room-type
              :documentation "Default room type to use")
   (room-size :initarg :room-size
              :reader   room-size))
  (:default-initargs
   :reverb .5))

(defun format-roomie-room (reflections)
  (format nil *roomie-room* reflections))

(defmethod (setf reverb) :after (new-value (obj roomie-room))
  (chnset *server* "reverb" new-value))

(defmethod initialize-instance :before ((obj roomie-room) &key room-type room-size)
  (assert (member room-type '(:small :medium :large :custom))
          (room-type) "Invalid ROOM-TYPE")
  (assert (or (and (eq :custom room-type) room-size)
              (not (eq :custom room-type)))
          () "CUSTOM room but no ROOM-DIM provided") )

(defmethod initialize-instance :after ((obj roomie-room) &key room-type room-size)
  (when (eq :custom room-type)
    (setf (slot-value obj 'room-size) (v! (max (x room-size) 2)
                                          (max (y room-size) 2)
                                          (max (z room-size) 2))))
  (init-channel "reverb" (slot-value obj 'reverb))
  (send *server* (format-roomie-room 1))
  (schedule *server* 1010 0 -1))

(defmethod room-size ((obj roomie-room))
  (ecase (slot-value obj 'room-type)
    (:small  (v!  3  4 3))
    (:medium (v! 10 10 3))
    (:large  (v! 20 25 7))
    (:custom (slot-value obj 'room-size))))

(defmethod room-type ((obj roomie-room))
  (ecase (slot-value obj 'room-type)
    (:custom 0)
    (:medium 1)
    (:small  2)
    (:large  3)))
