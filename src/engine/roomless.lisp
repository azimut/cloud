(in-package #:cloud)

;; diskin2 > hrtfmove2 = outs
;; diskin2 > hrtfmove2 = outs

(defvar *roomless-instr*
  "instr ~d
     kAz           chnget    \"azimut~d\"
     kElev         chnget    \"altitud~d\"
     kAmp          chnget    \"amplitud~d\"
     asig          diskin2   ~s, p4, p5, p6, 0, 32
     aleft, aright hrtfmove2 (asig * kAmp), kAz, kElev, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\"
                   outs      aleft * p7, aright * p7
   endin")

(defclass roomless (audio)
  ((pos      :initarg :pos
             :initform (v! 0 0 0)
             :accessor pos
             :documentation "audio position")
   (azimut   :initarg :azimut
             :accessor azimut
             :documentation "value to be used for hrtfmove2")
   (altitude :initarg :altitude
             :accessor altitude
             :documentation "value to be used for hrtfmove2")
   (amplitud :initarg :amplitud
             :accessor amplitud
             :documentation "value to be used for hrtfmove2"))
  (:documentation "sound effect, position based hrtfmove2.
                   diskin2 > hrtfmove2 = out"))

(defmethod initialize-instance :before ((obj roomless) &key pos)
  (check-type pos rtg-math.types:vec3))

(defmethod initialize-instance :after ((obj roomless) &key filename)
  (let* ((n (ninstr obj))
         (i (format nil *roomless-instr* n n filename)))
    (setf (slot-value obj 'instr)  i)
    (setup-channel "azimut"    i)
    (setup-channel "altitude"  i)
    (setup-channel "amplitude" i)))

(defun make-roomless (filename pos)
  (make-instance 'roomless :filename filename :pos pos))

;; https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
(defun compute-azimut (source-pos listener-pos listener-qrot)
  (- (* (atan (- (x source-pos) (x listener-pos))
              (- (z source-pos) (z listener-pos)))
        #.(/ 180f0 +PI+))
     (asin (* 2f0 (- (* (x listener-qrot) (z listener-qrot))
                     (* (w listener-qrot) (y listener-qrot)))))
     0d0))
(defun compute-altitude (source-pos listener-pos listener-qrot)
  (float
   (* (atan (- (y source-pos) (y listener-pos))
            (- (z source-pos) (z listener-pos)))
      #.(/ 180f0 +PI+))
   (atan (* 2f0 (+ (* (x listener-qrot) (y listener-qrot))
                   (* (z listener-qrot) (w listener-qrot))))
         (- 1f0 (* 2f0 (+ (expt (y listener-qrot) 2)
                          (expt (z listener-qrot) 2)))))
   0d0))
(defun compute-amplitude (source-pos listener-pos)
  (* .5d0 ; fudge factor
     (/ (1+ (+ (expt (- (x source-pos) (x listener-pos)) 2)
               (expt (- (y source-pos) (y listener-pos)) 2)
               (expt (- (z source-pos) (z listener-pos)) 2))))))

(defmethod (setf azimut) :after (value (obj roomless))
  (set-channel "azimut" (ninstr obj) value))
(defmethod (setf altitude) :after (value (obj roomless))
  (set-channel "altitude" (ninstr obj) value))
(defmethod (setf amplitude) :after (value (obj roomless))
  (set-channel "amplitude" (ninstr obj) value))

(defgeneric update (obj)
  (:documentation "channel updates for audio object"))

(defmethod update ((obj roomless))
  (let ((lpos (get-listener-pos))
        (lrot (get-listener-rot))
        (spos (pos obj)))
    (setf (azimut    obj) (compute-azimut    spos lpos lrot))
    (setf (altitude  obj) (compute-altitude  spos lpos lrot))
    (setf (amplitude obj) (compute-amplitude spos lpos))))
