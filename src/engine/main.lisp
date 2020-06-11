(in-package #:cloud)


;; https://www.fmod.com/resources/documentation-studio?version=2.0&page=parameters.html
;; - params: linear, discrete(01), labeled (from FMOD)

;; - multiple continuos audio (-sdlmix)
;; - delay (useful for layered effects of 1+ sounds)

;; + 3d audio
;; -- distance
;; -- direction
;; -- elevation
;; -- event orientation
;; -- event cone angle

;; - volume shifting (steps)
;; - pitch shifting (useful to make more sounds of a few, steps)
;; - reverb
;; ? oclussion

;; Useful helpers:
;; - Get sample 2 on channel 1
;; (csound::csoundgetspoutsample *c* 2 1)
;; - Get pointer of audio output working buffer (layout???
;; (csound::csoundgetspoutsample *c*)
;; csoundGetChannelPtr
;; - Can be used to send a new or a redinition of an existing one
;; (csound:compile-orc *c* "instr N ....")
;; - Put sfx in tables (f1, f2)
;; - Put songs in instruments with diskin
;; (make-play fox "i4" :rate 1 :skip 0 :loop 0 :amp 1)
;; (make-play pfox "i10")
;; (csound:compile-orc *c* "
;;   gasrc init 0
;;   instr 4
;;     ibcount active 4
;;     if (ibcount == 1) then
;;       ktrans linseg  1, 5, 2, 10, -2
;;       a1     diskin2 \"fox.wav\", p4, p5, p6, 0, 32
;;       gasrc = a1 * p7
;;     else
;;       turnoff
;;     endif
;;   endin
;;   instr 10
;;     iacount active 10
;;     if (iacount == 1) then
;;       kaz          linseg    0, p3, 720
;;       aleft,aright hrtfmove2 gasrc, kaz, 0, \"hrtf-44100-left.dat\", \"hrtf-44100-right.dat\"
;;                    outs aleft, aright
;;       clear gasrc
;;     else
;;       turnoff
;;     endif
;;   endin")
;; (progn (play-fox  3 :rate .8 :skip .8)
;;        (play-pfox 3))

;; env SSDIR
;; ar1[] diskin2
;; ifilcod[,       "file.wav"
;; kpitch[,        0.9           rate
;; iskiptim[,      0             skip seconds of audio (doesn't skip on loop)
;; iwrap[,         1             loop or not
;; iformat[,       0             raw fileformat...do not use
;; iwsize[,        0             interpolation of pitch
;; ibufsize[,      0             ?
;; iskipinit]]]]]]]

(defvar *file-to-instrument* (make-hash-table :test #'equal))
(defvar *instruments* 0)
;; TODO: restart?
(defun next-instrument (filename)
  (setf (gethash filename *file-to-instrument*)
        (or (gethash filename *file-to-instrument*)
            (incf *instruments*))))
(defun reset-instruments ()
  (clrhash *file-to-instrument*)
  (setf *instruments* 0))

(defclass audio ()
  ((filename :initarg :filename
             :reader   filename
             :documentation "location on disk")
   (instr    :accessor instr
             :documentation "csound instr string")
   (ninstr   :reader   ninstr
             :documentation "csound instrument number"))
  (:default-initargs
   :filename (error ":filename must be specified"))
  (:documentation "base audio class"))

(defmethod initialize-instance :before ((obj audio) &key filename)
  (assert (probe-file filename)))
(defmethod initialize-instance :after ((obj audio) &key filename)
  (setf (slot-value obj 'ninstr) (next-instrument filename)))

(defmethod (setf instr) :after (new-value (obj audio))
  (send *server* new-value))

(defun channel-string (name n)
  (format nil "~a~d" name n))
(defun set-channel (name value)
  (chnset *server* name value))
(defun init-channel (name default-value)
  (send *server* (format nil "chn_k ~s, 2" name))
  (set-channel name default-value))

(defun get-listener-pos () (v! 0 0 0))
(defun get-listener-rot () (q! 0f0 0f0 0f0 0f0))

(defun rot-x (q)
  "returns the EULER rotation in X from quaternion Q"
  (declare (type rtg-math.types:quaternion q))
  (atan (* 2f0 (+ (* (x q) (y q))
                  (* (z q) (w q))))
        (- 1f0 (* 2f0 (+ (expt (y q) 2)
                         (expt (z q) 2))))))
(defun rot-y (q)
  "returns the EULER rotation in Y from quaternion Q"
  (declare (type rtg-math.types:quaternion q))
  (asin (* 2 (- (* (x q) (z q))
                (* (w q) (y q))))))
#+nil
(progn
  (print (m3:rotation-from-euler
          (v! (rot-x (q:from-axis-angle (v! 1 0 0) 20f0)) 0 0)))
  (print (m3:rotation-from-axis-angle (v! 1 0 0) 20f0)))
