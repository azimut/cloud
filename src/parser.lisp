(in-package #:cloud)

;; NOTE: unused
(defun get-opcode (s)
  "return a list of strings with each opcode in orc S"
  (declare (type string s))
  (let* ((instr (serapeum:collecting
                  (cl-ppcre:do-scans
                      (ms me rs re "(?:^|\\n)\\s*(opcode\\s+[0-9a-zA-Z]+)" s)
                    (collect (aref rs 0)))))
         (endin (serapeum:collecting
                  (cl-ppcre:do-scans
                      (ms me rs re "(?:^|\\n)\\s*(endop)" s)
                    (collect (aref re 0))))))
    (loop :for start :in instr
          :for end   :in endin
          :collect (subseq s start end))))

;; FIXME: not sure what to return when no pN is used
(defun get-p-max (s)
  "returns the max parameter number used in instrument S"
  (declare (type string s))
  (let* ((pns (cl-ppcre:all-matches-as-strings "p\\d+" s))
         (ns  (mapcar (alexandria:compose #'parse-integer
                                          #'str:s-last)
                      pns))
         (n   (alexandria:extremum ns #'>)))
    n))

(defun mono-to-stereo (s)
  "adds 2 new params to instr S"
  (let ((p-max (get-p-max s)))
    (cl-ppcre:regex-replace " out\\s+\(.*\)"
                            s
                            (format nil "outs (\\{1})*p~d,(\\{1})*p~d"
                                    (+ 1 p-max)
                                    (+ 2 p-max)))))

(defun get-instr (s)
  "return a list of strings with each instr in orc S"
  (declare (type string s))
  (let* ((instr (serapeum:collecting
                  (cl-ppcre:do-scans
                      (ms me rs re "(?:^|\\n)\\s*(instr\\s+[0-9a-zA-Z]+)" s)
                    (collect (aref rs 0)))))
         (endin (serapeum:collecting
                  (cl-ppcre:do-scans (ms me rs re "(?:^|\\n)\\s*(endin)" s)
                    (collect (aref re 0))))))
    (loop :for start :in instr
          :for end   :in endin
          :collect (subseq s start end))))

(defun parse-orc (s)
  "returns the orc, changes mono to stereo, remove comments"
  (declare (type string s))
  (let* ((orc       (arrows:->> (str:replace-all ";.*" "" s)
                                (str:lines)
                                (remove-if #'str:blankp)
                                (str:unlines)))
         (soundin-p (cl-ppcre:scan "soundin" orc))
         (mono-p    (cl-ppcre:scan "nchnls\\s*=\\s*1" orc)))
    (when soundin-p (error "soundin not supported"))
    (str:unlines
     (loop :for instr :in (get-instr orc)
           :if mono-p
             :collect (mono-to-stereo instr)
           :else
             :collect instr))))

(defun parse-sco (s)
  "returns only the fN wavetables on the score, remove comments, spaces and
   zeros from fN wavetable definitions"
  (declare (type string s))
  (let* ((score (cl-ppcre:regex-replace-all ";.*" s ""))
         (score (cl-ppcre:regex-replace-all "f[ ]+\(\\d+\)" score "f\\1"))
         (score (cl-ppcre:regex-replace-all "f0+\(\\d+\)" score "f\\1"))
         ;; Return only wavetables
         (score (format
                 nil
                 "~{~A~% ~}"
                 (cl-ppcre:all-matches-as-strings "f\\d+ .*" score))))
    score))

;; FIXME: assumes globals are only defined before the first instr
;;        declaration appears
(defun parse-globals (s)
  "returns a string with all globals"
  (declare (type string s))
  (let* ((orc         (cl-ppcre:regex-replace-all ";.*" s ""))
         (first-instr (cl-ppcre:scan "instr\\s+\\d+" orc))
         (globals     (subseq orc 0 first-instr)))
    globals))


;; NOTE: before running this try the sound on the CLI with:
;; $ csound -odac 326a.{orc,sco}
;; TODO: support only .orc
(defun make-orc (name &key sco orc globals
                           filename (filepath *default-csound-path*)
                           orc-path sco-path)
  "This function creates a new orchestra file, reading score wave tables too"
  (assert (keywordp name))
  ;; Find files if parameters provided
  (when filename
    (setf orc-path (resolve-csound-path name ".orc" filepath))
    (setf sco-path (resolve-csound-path name ".sco" filepath)))
  ;; Read into vars
  (when (and orc-path sco-path)
    (setf globals (parse-globals (alexandria:read-file-into-string orc-path)))
    (setf orc     (parse-orc (alexandria:read-file-into-string orc-path)))
    (setf sco     (parse-sco (alexandria:read-file-into-string sco-path))))
  (setf (gethash name *orcs*)
        (make-instance 'orc
                       :name name
                       :file filepath
                       :globals globals
                       :sco sco
                       :orc orc)))
