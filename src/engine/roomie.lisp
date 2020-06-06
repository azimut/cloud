(in-package #:cloud)
;; hrtfearly > hrtfreverb
;; hrtfearly >
;; TODO: define listener globals
;; TODO: define hrtfreverb infinite instrument?
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

;; TODO: other room arguments for custom are missing
;; TODO: amp?
(defclass roomie (audio)
  ((pos       :initarg :pos
              :accessor pos
              :initform #(0f0 0f0 0f0)
              :documentation "3d position")
   (room-type :initarg :room-type
              :reader   room-type
              :initform :custom
              :documentation "Default room type to use")
   (room-dim  :initarg :room-dim
              :reader   room-dim
              :initform #(10f0 10f0 10f0)))
  (:documentation "room based sound effect"))

(defmethod initialize-instance :before ((obj roomie) &key room-dim)
  (assert (member (slot-value obj 'room-type) '(:small :medium :large :custom))
          () "Invalid ROOM-TYPE")
  (assert (and room-dim (eq :custom (slot-value obj 'room-type)))
          () "CUSTOM room but no ROOM-DIM provided"))

(defmethod initialize-instance :after ((obj roomie) &key)
  (let ((n (ninstr obj)))
    (init-channel "srcx" n)
    (init-channel "srcy" n)
    (init-channel "srcz" n)))

(defmethod pos ((obj roomie))
  (let ((dim (room-dim obj))
        (pos (slot-value obj 'pos)))
    (vector (+ (aref pos 0) (/ (aref dim 0) 2f0))
            (+ (aref pos 1) (/ (aref dim 1) 2f0))
            (+ (aref pos 2) (/ (aref dim 2) 2f0)))))

(defmethod (setf pos) :after (value (obj roomie))
  (let ((n (ninstr obj)))
    (set-channel "srcx" n (aref value 0))
    (set-channel "srcy" n (aref value 1))
    (set-channel "srcz" n (aref value 2))))

(defmethod room-dim ((obj roomie))
  (ecase (slot-value obj 'room-type)
    (:small  #( 3  4 3))
    (:medium #(10 10 3))
    (:large  #(20 25 7))
    (:custom (slot-value obj 'room-dim))))

(defmethod room-type ((obj roomie))
  (ecase (slot-value obj 'room-type)
    (:custom 0)
    (:medium 1)
    (:small  2)
    (:large  3)))


;; lisPos = Osc.StringToOscMessage("/listenerPositions "
;;                                 + (listener.position.x + (roomSizeInMeters[0]/2)).ToString() + " "
;;                                 + (listener.position.z + (roomSizeInMeters[2]/2)).ToString() + " "
;;                                 + (listener.position.y + (roomSizeInMeters[1]/2)).ToString() + " "
;;                                 + (listener.rotation.eulerAngles[1].ToString()) );

(defun init-room ()
  ;; Setup listener
  (init-channel "dstx" 999)
  (init-channel "dsty" 999)
  (init-channel "dstz" 999))

(defmethod update-listener ((obj roomie) listener-pos)
  (set-channel "dstx" 999 (x listener-pos))
  (set-channel "dsty" 999 (y listener-pos))
  (set-channel "dstz" 999 (z listener-pos)))
