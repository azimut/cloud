(in-package #:cloud)

(defmacro at (time function &rest arguments)
  `(scheduler:sched-add *scheduler*
                        (+ ,time (scheduler:sched-time *scheduler*))
                        ,function ,@arguments))

(declaim (inline now))
(defun now ()
  (scheduler:sched-time *scheduler*))

(defun midihz (midi)
  (* (expt 2 (/ (- midi 69) 12)) 440f0))

;; https://github.com/csound/csound/blob/2709c99b851a17b5476903bcc50af83f43e12446/OOps/aops.c
(defun keynum->pch (midi)
  (let* (;; Lowest midi note is 3.00 in oct & pch formats
         (midinote0 3f0)
         ;; Convert Midi Note number to 8ve.decimal format
         (octdec (+ (/ midi 12) midinote0))
         ;; then convert to 8ve.pc format
         (fract  (mod octdec 1))
         (fract  (* fract 0.12))
         (oct    (floor octdec)))
    (+ oct fract)))

;;--------------------------------------------------

(defun csound-send-event (iname duration vars)
  (declare (type string iname) (type number duration) (type list vars))
  (csound:csoundreadscore *c* (format nil "~a 0 ~a ~{~A~^ ~}" iname duration vars)))

(defgeneric playcsound (instrument duration &rest rest))
(defmethod playcsound ((iname string) (duration number) &rest rest)
  "pitchless sound"
  (when (> duration 0)
    (let ((vars-only (remove-if #'keywordp rest)))
      (csound-send-event iname duration vars-only))))

(defgeneric playcsound-freq (instrument duration keynum &rest rest))
(defmethod playcsound-freq ((iname string) (duration number) (keynum fixnum) &rest rest)
  "midi number to hz sound"
  (when (and (> keynum 0) (> duration 0))
    (setf (getf rest :freq) (midihz keynum))
    (let ((vars-only (remove-if #'keywordp rest)))
      (csound-send-event iname duration vars-only)))
  keynum)
(defmethod playcsound-freq ((iname string) (duration number) (keynum list) &rest rest)
  (mapc (lambda (k)
          (when (and (> k 0) (> duration 0))
            (setf (getf rest :freq) (midihz k))
            (let ((vars-only (remove-if #'keywordp rest)))
              (csound-send-event iname duration vars-only))))
        keynum))

(defgeneric playcsound-key (instrument duration keynum &rest rest))
(defmethod playcsound-key ((iname string) (duration number) (keynum integer) &rest rest)
  "midi keynum to pch"
  (when (and (> keynum 0) (> duration 0))
    (setf (getf rest :keynum) (keynum->pch keynum))
    (let ((vars-only (remove-if #'keywordp rest)))
      (csound-send-event iname duration vars-only)))
  keynum)
(defmethod playcsound-key ((iname string) (duration number) (keynum list) &rest rest)
  (mapc (lambda (k)
          (when (and (> duration 0) (> k 0))
            (setf (getf rest :keynum) (keynum->pch k))
            (let ((vars-only (remove-if #'keywordp rest)))
              (csound-send-event iname duration vars-only))))
        keynum))

(defgeneric playcsound-midi (instrument duration keynum &rest rest))
(defmethod playcsound-midi ((iname string) (duration number) (keynum fixnum) &rest rest)
  "midi keynum play"
  (when (and (> keynum 0) (> duration 0))
    (setf (getf rest :midi) keynum)
    (let ((vars-only (remove-if #'keywordp rest)))
      (csound-send-event iname duration vars-only)))
  keynum)
(defmethod playcsound-midi ((iname string) (duration number) (keynum list) &rest rest)
  (mapc (lambda (k)
          (when (and (> k 0) (> duration 0))
            (setf (getf rest :midi) k)
            (let ((vars-only (remove-if #'keywordp rest)))
              (csound-send-event iname duration vars-only))))
        keynum))

;;--------------------------------------------------

(defmacro make-play (name i &rest rest)
  "this macro will create a new (play-NAME) function wrapper of either
   playcsound or playcsound-key, with each &key defined on the function"
  (print name)
  ;;(assert (and (symbolp name) (not (keywordp name))))
  (let ((fname    (intern (format nil "~A-~A" 'play name)))
        (fnamearp (intern (format nil "~A-~A-~A" 'play name 'arp))))
    (cond ((position :keynum rest)
           ;;--------------------------------------------------
           ;; CPH - Handles normal instrumentes with a single note in PCH
           ;;--------------------------------------------------
           `(progn
              (defun ,fname (keynum duration &key ,@(remove-if
                                                     #'null
                                                     (loop :for (x y) :on rest :by #'cddr
                                                           :collect
                                                              (let* ((sn (symbol-name x))
                                                                     (k  (intern sn)))
                                                                (when (not (eq :keynum x))
                                                                  (list k y))))))
                (declare (type (or integer list) keynum) (number duration)
                         (optimize speed))
                (playcsound-key ,i duration keynum
                                ,@(loop :for (k v) :on rest :by #'cddr :append
                                           (if (eq k :keynum)
                                               (list k 127) ;; dummy value...
                                               (list k (intern (symbol-name k)))))))
              (defun ,fnamearp (keynums duration offset
                                &key ,@(remove-if
                                        #'null
                                        (loop :for (x y) :on rest :by #'cddr
                                              :collect
                                                 (let* ((sn (symbol-name x))
                                                        (k  (intern sn)))
                                                   (when (not (eq :keynum x))
                                                     (list k y))))))
                (declare (list keynums) (number duration offset)
                         (optimize speed))
                (loop :for keynum :in (cdr keynums)
                      :for i :from offset :by offset
                      :with now = (now)
                      :initially (playcsound-key
                                  ,i duration (car keynums)
                                  ,@(loop :for (k v) :on rest :by #'cddr :append
                                             (if (eq k :keynum)
                                                 (list k 127) ;; dummy value...
                                                 (list k (intern (symbol-name k))))))
                      :do
                         (scheduler:sched-add
                          *scheduler*
                          (+ i (scheduler:sched-time *scheduler*))
                          #'playcsound-key ,i duration keynum
                          ,@(loop :for (k v) :on rest :by #'cddr :append
                                     (if (eq k :keynum)
                                         (list k 127) ;; dummy value...
                                         (list k (intern (symbol-name k)))))))
                NIL)))
          ;;--------------------------------------------------
          ;; FREQ - Handles normal instruments with a single note in Hz
          ;;--------------------------------------------------
          ((position :freq rest)
           `(progn
              (defun ,fname (keynum duration
                             &key ,@(remove-if
                                     #'null
                                     (loop :for (x y) :on rest :by #'cddr
                                           :collect
                                              (let* ((sn (symbol-name x))
                                                     (k  (intern sn)))
                                                (when (not (eq :freq x))
                                                  (list k y))))))
                (playcsound-freq ,i duration keynum
                                 ,@(loop :for (k v) :on rest :by #'cddr :append
                                            (if (eq k :freq)
                                                (list k 440) ;; dummy value...
                                                (list k (intern (symbol-name k)))))))
              (defun ,fnamearp (keynums duration offset
                                &key ,@(remove-if
                                        #'null
                                        (loop :for (x y) :on rest :by #'cddr
                                              :collect
                                                 (let* ((sn (symbol-name x))
                                                        (k  (intern sn)))
                                                   (when (not (eq :freq x))
                                                     (list k y))))))
                (loop :for keynum :in (cdr keynums)
                      :for i :from offset :by offset
                      :with now = (now)
                      :initially (,fname (car keynums) duration
                                         ,@(remove-if
                                            #'null
                                            (loop :for (x y) :on rest :by #'cddr
                                                  :append
                                                     (let* ((sn (symbol-name x))
                                                            (k  (intern sn)))
                                                       (when (not (eq :freq x))
                                                         (list x k))))))
                      :do
                         (scheduler:sched-add
                          *scheduler*
                          (+ i (scheduler:sched-time *scheduler*))
                          #',fname keynum duration
                          ,@(remove-if
                             #'null
                             (loop :for (x y) :on rest :by #'cddr
                                   :append
                                      (let* ((sn (symbol-name x))
                                             (k  (intern sn)))
                                        (when (not (eq :freq x))
                                          (list x k)))))))
                NIL)))
          ;;--------------------------------------------------
          ((position :midi rest)
           `(progn
              (defun ,fname (midi duration &key ,@(remove-if
                                                   #'null
                                                   (loop :for (x y) :on rest :by #'cddr
                                                         :collect
                                                            (let* ((sn (symbol-name x))
                                                                   (k  (intern sn)))
                                                              (when (not (eq :midi x))
                                                                (list k y))))))
                (declare (type (or integer list) midi) (number duration)
                         (optimize speed))
                (playcsound-midi ,i duration midi
                                 ,@(loop :for (k v) :on rest :by #'cddr :append
                                            (if (eq k :midi)
                                                (list k 127) ;; dummy value...
                                                (list k (intern (symbol-name k)))))))
              (defun ,fnamearp (midis duration offset
                                &key ,@(remove-if
                                        #'null
                                        (loop :for (x y) :on rest :by #'cddr
                                              :collect
                                                 (let* ((sn (symbol-name x))
                                                        (k  (intern sn)))
                                                   (when (not (eq :midi x))
                                                     (list k y))))))
                (declare (list midis) (number duration offset)
                         (optimize speed))
                (loop
                  :for midi :in (cdr midis)
                  :for i :from offset :by offset
                  :with now = (now)
                  :initially (playcsound-midi
                              ,i duration (car midis)
                              ,@(loop :for (k v) :on rest :by #'cddr :append
                                         (if (eq k :midi)
                                             (list k 127) ;; dummy value...
                                             (list k (intern (symbol-name k))))))
                  :do
                     (scheduler:sched-add
                      *scheduler*
                      (+ i (scheduler:sched-time *scheduler*))
                      #'playcsound-midi ,i duration midi
                      ,@(loop :for (k v) :on rest :by #'cddr :append
                                 (if (eq k :midi)
                                     (list k 127) ;; dummy value...
                                     (list k (intern (symbol-name k)))))))
                NIL)))
          ;;--------------------------------------------------
          (t
           ;; Handles instruments without keynum
           `(defun ,fname (duration &key ,@(loop :for (x y) :on rest :by #'cddr
                                                 :collect
                                                    (let* ((sn (symbol-name x))
                                                           (k  (intern sn)))
                                                      (list k y))))
              (declare (number duration) (optimize speed))
              (playcsound ,i duration
                          ,@(loop :for (k v) :on rest :by #'cddr :append
                                     (list k (intern (symbol-name k))))))))))
