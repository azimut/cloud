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
   #:udp
   #:connect #:disconnect #:reconnect
   #:send #:chnset #:schedule #:readscore))
