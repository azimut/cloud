(in-package #:cloud)

;; TODO: free instrument?

(defvar *roomless-instr*
  "instr ~d
     kAz           chnget    \"azimut~d\"
     kElev         chnget    \"altitude~d\"
     kAmp          chnget    \"amplitude~d\"
     asig          diskin2   ~s, p4, p5, p6, 0, 32
     aleft, aright hrtfmove2 (asig * kAmp), kAz, kElev, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\"
                   outs      aleft * p7, aright * p7
   endin"
  "diskin2 > hrtfmove2 = out")

(defclass roomless (audio)
  ((pos       :initarg :pos
              :accessor pos
              :documentation "audio position")
   (azimut    :initarg :azimut
              :accessor azimut
              :documentation "value to be used for hrtfmove2")
   (altitude  :initarg :altitude
              :accessor altitude
              :documentation "value to be used for hrtfmove2")
   (amplitude :initarg :amplitude
              :accessor amplitude
              :documentation "value to be used for hrtfmove2"))
  (:default-initargs
   :pos (v! 0 0 0))
  (:documentation "sound effect, position based hrtfmove2"))

(defun format-roomless (n filename)
  (format nil *roomless-instr* n n n n filename))

(defmethod initialize-instance :before ((obj roomless) &key pos)
  (check-type pos rtg-math.types:vec3))

(defmethod initialize-instance :after ((obj roomless) &key filename)
  (let* ((i (ninstr obj)))
    (setf (slot-value obj 'instr) (format-roomless i filename))
    (send *server* (format nil "chn_k \"~a~d\", 2" "azimut"    i))
    (send *server* (format nil "chn_k \"~a~d\", 2" "altitude"  i))
    (send *server* (format nil "chn_k \"~a~d\", 2" "amplitude" i))
    (send *server* (instr obj))))

(defun make-roomless (filename pos)
  (make-instance 'roomless :filename filename :pos pos))

;; https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
(defun compute-azimut (source-pos listener-pos listener-qrot)
  (- (* (atan (- (x source-pos) (x listener-pos))
              (- (z source-pos) (z listener-pos)))
        #.(/ 180f0 +PI+))
     (asin (* 2 (- (* (x listener-qrot) (z listener-qrot))
                   (* (w listener-qrot) (y listener-qrot)))))))
(defun compute-altitude (source-pos listener-pos listener-qrot)
  (+ (* (atan (- (y source-pos) (y listener-pos))
              (- (z source-pos) (z listener-pos)))
        #.(/ 180f0 +PI+))
     (atan (* 2f0 (+ (* (x listener-qrot) (y listener-qrot))
                     (* (z listener-qrot) (w listener-qrot))))
           (- 1f0 (* 2f0 (+ (expt (y listener-qrot) 2)
                            (expt (z listener-qrot) 2)))))))
(defun compute-amplitude (source-pos listener-pos)
  (* .5 ; fudge factor
     (/ 1 (+ 1 (+ (expt (- (x source-pos) (x listener-pos)) 2)
                  (expt (- (y source-pos) (y listener-pos)) 2)
                  (expt (- (z source-pos) (z listener-pos)) 2))))))

(defmethod (setf azimut) :after (value (obj roomless))
  (set-channel "azimut" (ninstr obj) value))
(defmethod (setf altitude) :after (value (obj roomless))
  (set-channel "altitude" (ninstr obj) value))
(defmethod (setf amplitude) :after (value (obj roomless))
  (set-channel "amplitude" (ninstr obj) value))

#+nil
(defmethod (setf pos) :after (new-pos (obj roomless))
  (setf (azimut    obj) (compute-azimut    new-pos lpos lrot))
  (setf (altitude  obj) (compute-altitude  new-pos lpos lrot))
  (setf (amplitude obj) (compute-amplitude new-pos lpos)))

(defgeneric update (obj)
  (:documentation "channel updates for audio object"))

(defmethod update ((obj roomless))
  (let ((lpos (v! 0 0 0) ;;(get-listener-pos)
              )
        (lrot (get-listener-rot)
              )
        (spos (v! (+ -2 (random 4)) 0 0) ;;(pos obj)
              ))
    (setf (azimut    obj) (compute-azimut    spos lpos lrot))
    (setf (altitude  obj) (compute-altitude  spos lpos lrot))
    (setf (amplitude obj) (compute-amplitude spos lpos))))


