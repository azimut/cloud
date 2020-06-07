(in-package #:cloud)
;; hrtfearly > hrtfreverb
;; hrtfearly >
;; TODO: define listener globals
;; TODO: other room arguments for custom are missing
;; TODO: amp?
;; TODO: initial source listener position update?
;; custom room needs:
;; - listener rotation
;; - room-dim enforce 2ms MIN in all axis
;; hrtfreverb needs:
;; - reverb ammount (channel), which applies to a "delay" opcode (instr 10)
;; - an instr playing that "hrtfreverb" opcode
;; - input global of audio
;; - zero global audio

(defparameter *roomie-listener*
  "gklisxSmooth, gklisySmooth, gkliszSmooth, gklisdirSmooth init 0
   instr 1001
     ibcount active 1001
     if (ibcount == 1) then
       klisx, klisy, klisz, klisdir init 0
       gklisxSmooth   port klisx,   .025
       gklisySmooth   port klisy,   .025
       gkliszSmooth   port klisz,   .025
       gklisdirSmooth port klisdir, .025
     else
       turnoff
     endif
   endin"
  "Instrument to constantly smooth listener params.")

(defclass listener ()
  ((server :initform *server*
           :initarg  :server
           :reader server)
   (pos    :initform (v! 0 0 0)
           :accessor pos)))

(defmethod initialize-instance :before ((obj listener) &key)
  (check-type (slot-value obj 'server) csound))

(defmethod initialize-instance :after ((obj listener) &key)
  (with-slots (server) obj
    (chnk server "klisx")
    (chnk server "klisy")
    (chnk server "klisz")
    (chnk server "klisdir")
    (send server *roomie-listener*)
    (schedule server 1001 0 -1)))

(defmethod (setf pos) :after (new-pos (obj listener))
  (chnset (server obj) "klisx" (x new-pos))
  (chnset (server obj) "klisy" (y new-pos))
  (chnset (server obj) "klisz" (z new-pos)))

(defparameter *roomie-instr*
  "instr ~d
     kx, ky, kz, kamp init 0
     kx    chnget  \"srcx~d\"
     ky    chnget  \"srcy~d\"
     kz    chnget  \"srcz~d\"
     kamp  chnget  \"amplitud~d\"
     kSrcx port    kx, .025
     kSrcy port    ky, .025
     kSrcz port    kz, .025
     asig  diskin2 ~s, p4, p5, p6, 0, 32

     aleft, aright, irt60low, irt60high, imfp hrtfearly asig, kSrcx, kSrcy, kSrcz, gklisxSmooth, gklisySmooth, gkliszSmooth, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\", ~d
           outs      aleft * p7, aright * p7
   endin")

(defclass roomie (audio)
  ((pos       :initarg :pos
              :accessor pos
              :initform (v! 0 0 0)
              :documentation "3d position")
   (room-type :initarg :room-type
              :reader   room-type
              :initform :custom
              :documentation "Default room type to use")
   (room-size :initarg :room-size
              :reader   room-size
              :initform (v! 2 2 2)))
  (:documentation "room based sound effect"))

(defmethod initialize-instance :before ((obj roomie) &key room-size)
  (assert (member (slot-value obj 'room-type) '(:small :medium :large :custom))
          () "Invalid ROOM-TYPE")
  (assert (and room-size (eq :custom (slot-value obj 'room-type)))
          () "CUSTOM room but no ROOM-DIM provided"))

(defmethod initialize-instance :after ((obj roomie) &key)
  (let ((n (ninstr obj)))
    (init-channel "srcx" n)
    (init-channel "srcy" n)
    (init-channel "srcz" n)))

(defmethod (setf pos) :after (value (obj roomie))
  (let ((n (ninstr obj)))
    (set-channel "srcx" n (x value))
    (set-channel "srcy" n (y value))
    (set-channel "srcz" n (z value))))

(defmethod room-size ((obj roomie))
  (ecase (slot-value obj 'room-type)
    (:small  (v!  3  4 3))
    (:medium (v! 10 10 3))
    (:large  (v! 20 25 7))
    (:custom (slot-value obj 'room-size))))

(defmethod room-type ((obj roomie))
  (ecase (slot-value obj 'room-type)
    (:custom 0)
    (:medium 1)
    (:small  2)
    (:large  3)))


(defmethod upload-listener (()))
(defmethod upload-source ((source roomie) (listener listener))
  (let ((spos (pos source))
        (lpos (pos listener))
        (size (room-size source)))
    (v3:*s size .5)))
