;;;; package.lisp

(defpackage #:cloud
  (:use #:cl)
  (:export
   ;;
   #:list-orcs
   #:get-orchestra
   #:sco
   #:orc
   ;;
   #:make-csound #:csound
   #:connect #:disconnect #:reconnect
   #:send #:chnset #:schedule #:readscore))
