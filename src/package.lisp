;;;; package.lisp

(uiop:define-package #:cloud
  (:use #:cl)
  (:shadow #:load)
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
