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
  ((pos :initarg :pos
        :accessor pos
        :documentation "audio position"))
  (:default-initargs
   :pos (v! 0 0 0))
  (:documentation "sound effect, position based hrtfmove2"))

(defun format-roomless (n filename)
  (format nil *roomless-instr* n n n n filename))

(defmethod initialize-instance :before ((obj roomless) &key pos)
  (check-type pos rtg-math.types:vec3))

(defmethod initialize-instance :after ((obj roomless) &key filename)
  (let* ((i (ninstr obj)))
    (setf (instr obj) (format-roomless i filename))
    (init-channel (format nil "azimut~d"    i) 0.0)
    (init-channel (format nil "altitude~d"  i) 0.0)
    (init-channel (format nil "amplitude~d" i) 0.0)))

(defun make-roomless (filename pos)
  (make-instance 'roomless :filename filename :pos pos))

;; https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
(defun compute-azimut (source-pos listener-pos listener-qrot)
  (- (* (atan (- (x source-pos) (x listener-pos))
              (- (z source-pos) (z listener-pos)))
        #.(/ 180f0 +PI+))
     (rot-y listener-qrot)))
(defun compute-altitude (source-pos listener-pos listener-qrot)
  (+ (* (atan (- (y source-pos) (y listener-pos))
              (- (z source-pos) (z listener-pos)))
        #.(/ 180f0 +PI+))
     (rot-x listener-qrot)))
(defun compute-amplitude (source-pos listener-pos)
  (* .5 ; fudge factor
     (/ 1 (+ 1 (+ (expt (- (x source-pos) (x listener-pos)) 2)
                  (expt (- (y source-pos) (y listener-pos)) 2)
                  (expt (- (z source-pos) (z listener-pos)) 2))))))

(defmethod (setf pos) :after (new-pos (obj roomless))
  (let ((lpos (get-listener-pos))
        (lrot (get-listener-rot)))
    (set-channel (format nil "azimut~d"    (ninstr obj)) (compute-azimut    new-pos lpos lrot))
    (set-channel (format nil "altitude~d"  (ninstr obj)) (compute-altitude  new-pos lpos lrot))
    (set-channel (format nil "amplitude~d" (ninstr obj)) (compute-amplitude new-pos lpos))))
