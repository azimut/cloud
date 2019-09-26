(in-package #:cloud)

(defun regex-count (regex s)
  (declare (string regex s))
  (let ((matches (length (cl-ppcre:all-matches regex s))))
    (when matches
      (/ matches 2))))

(defun get-fn (score)
  "returns a list of string of integers with each match of the form Fn,
   where n is a number"
  (declare (string score))
  (let* ((l (cl-ppcre:all-matches-as-strings
             "f\\d+"
             score))
         (l (mapcar
             (lambda (x) (subseq x 1))
             l)))
    l))

(defun replace-var (orc index key value)
  (declare (type string orc))
  (let ((replacement (format nil "~a~a~a~%" "\\{1}" value "\\{2}")))
    (cl-ppcre:regex-replace-all
     (concatenate 'string
                  "\(" key "\\s+[^,]+,[^,]+,\)\\s*" index "\(.*\)\\n")
     orc
     replacement)))

;; NOTE: this was so weird and annoying...regex...i didn't miss you
(defun replace-wavetables (orc wavetables-hash)
  (declare (type string orc) (type hash-table wavetables-hash))
  (maphash (lambda (k v)
             (setf orc (replace-var orc k "oscili" v))
             (setf orc (replace-var orc k "table"  v))
             (setf orc (replace-var orc k "tablei" v))
             (setf orc (replace-var orc k "vco"    v)))
           wavetables-hash)
  orc)

(defun merge-orcs (&rest orchestras)
  (let ((n-instruments 0)
        (instruments)
        (n-wavetables 1)
        (wavetables)
        (wavetables-hash (make-hash-table :test #'equal))
        (globals))
    (loop :for orchestra :in orchestras
          :do
             (with-slots (orc sco) orchestra
               ;; SCO
               (loop :for f :in (get-fn sco)
                     :for fn :from n-wavetables
                     :with temp-wavetable = sco
                     :finally (setf wavetables (concatenate 'string
                                                            wavetables
                                                            temp-wavetable))
                     :do
                        (setf (gethash f wavetables-hash) fn)
                        (setf temp-wavetable (cl-ppcre:regex-replace
                                              (format nil "~a~a" "f" f)
                                              temp-wavetable
                                              (format nil "f~d" fn)))
                        (incf n-wavetables))
               ;; GLOBALS
               (setf globals (concatenate 'string globals (globals orchestra)))
               ;; ORC
               (let ((tmporc (replace-wavetables orc wavetables-hash)))
                 (clrhash wavetables-hash)
                 (setf instruments (stich instruments tmporc))
                 (incf n-instruments (regex-count "instr\\s+\\d+" tmporc)))))
    ;; ORC: Template instruments
    (setf instruments (cl-ppcre:regex-replace-all "instr\\s+\\d+"
                                                  instruments
                                                  "instr ~a"))
    ;; ORC: New Instruments numbers
    ;; FIXME: Ensure we support these many instruments
    (assert (< n-instruments 10))
    (setf instruments (format nil instruments 1 2 3 4 5 6 7 8 9 10))
    ;; RETURN both a new ORC and SCO
    (setf *tmporc*
          (make-instance
           'orc
           :globals nil
           :name :tmporc
           :orc (stich *csound-globals* globals instruments)
           :sco wavetables))
    *tmporc*))
