(in-package #:cloud)
;; TODO: assumes 1(one) reverb at the time
(defvar *roomie-room*
  "gamain init 0
   gimfp, gilowrt60, gihighrt60 init 0
   instr 1010
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
  ((reverb     :accessor reverb
               :initarg :reverb
               :documentation "reverb fudge factor")
   (room-type  :initarg  :room-type
               :reader  room-type
               :documentation "Default room type to use")
   (room-size  :initarg  :room-size
               :reader  room-size)
   (order      :initarg  :order
               :reader  order
               :documentation "more reflections")
   (wall-high  :initarg  :wall-high)
   (wall-low   :initarg  :wall-low)
   (wall-gain1 :initarg  :wall-gain1)
   (wall-gain2 :initarg  :wall-gain2)
   (wall-gain3 :initarg  :wall-gain3)
   (piso-high  :initarg  :piso-high)
   (piso-low   :initarg  :piso-low)
   (piso-gain1 :initarg  :piso-gain1)
   (piso-gain2 :initarg  :piso-gain2)
   (piso-gain3 :initarg  :piso-gain3)
   (ceil-high  :initarg  :ceil-high)
   (ceil-low   :initarg  :ceil-low)
   (ceil-gain1 :initarg  :ceil-gain1)
   (ceil-gain2 :initarg  :ceil-gain2)
   (ceil-gain3 :initarg  :ceil-gain3))
  (:default-initargs
   :reverb     0.5
   :order      1
   :wall-high  0.3
   :wall-low   0.1
   :wall-gain1 0.75
   :wall-gain2 0.96
   :wall-gain3 0.9
   :piso-high  0.6
   :piso-low   0.1
   :piso-gain1 0.95
   :piso-gain2 0.6
   :piso-gain3 0.35
   :ceil-high  0.2
   :ceil-low   0.1
   :ceil-gain1 1.0
   :ceil-gain2 1.0
   :ceil-gain3 1.0))

(defun format-roomie-room (order)
  (format nil *roomie-room* order))

(defmethod (setf reverb) :after (new-value (obj roomie-room))
  (set-channel "reverb" new-value))

(defmethod initialize-instance :before ((obj roomie-room) &key room-type room-size order)
  (assert (member room-type '(:small :medium :large :custom))
          (room-type) "Invalid ROOM-TYPE")
  (assert (or (and (eq :custom room-type) room-size)
              (not (eq :custom room-type)))
          () "CUSTOM room but no ROOM-DIM provided")
  (assert (or (and order (<= 0 order 4)) (not order))
          (order) "ORDER out of range 0-4"))

(defmethod initialize-instance :after ((obj roomie-room) &key room-type room-size)
  (when (eq :custom room-type)
    (setf (slot-value obj 'room-size) (v! (max (x room-size) 2)
                                          (max (y room-size) 2)
                                          (max (z room-size) 2))))
  (init-channel "reverb" (slot-value obj 'reverb))
  (send *server* (format-roomie-room (order obj)))
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
