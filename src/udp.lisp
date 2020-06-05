(in-package #:cloud)

;; Helpers for sending UDP messages to a csound instance initilize
;;
;; $ csound --port=10000 -m3 -odac --nchnls=2 -n
;;
;; Reference:
;; https://csound.com/docs/manual/udpserver.html
;; http://write.flossmanuals.net/csound/web-based-csound/
;; https://github.com/LispCookbook/cl-cookbook/blob/95086d1f8f5d64b3c4ec83523fbaba0e1ac52447/sockets.md

(defclass csound ()
  ((socket :initarg :socket :accessor socket)
   (host   :initarg :host   :reader   host)
   (port   :initarg :port   :reader   port)
   (tempo  :initarg :tempo  :accessor tempo))
  (:default-initargs
   :socket nil
   :tempo 60
   :host "127.0.0.1"
   :port 10000))

(defvar *server*)

(defun make-csound (&rest rest)
  (apply #'make-instance 'csound rest))

(defmethod connect ((server csound))
  (setf (socket server)
        (usocket:socket-connect (host server) (port server) :protocol :datagram)))

(defmethod disconnect ((server csound))
  (when (socket server)
    (usocket:socket-close (socket server))))

(defmethod reconnect ((server csound))
  (disconnect server)
  (connect server))

(defmethod send ((server csound) (msg string))
  (usocket:socket-send (socket server) msg (length msg)))

(defmethod (setf tempo) :after (new-value (server csound))
  (let ((msg (format nil "set_tempo ~d" new-value)))
    (send server msg)))

(defmethod chnset ((server csound) (channel string) (value number))
  (let ((msg (format nil "chnset ~a,\"~a\"" value channel)))
    (send server msg)))

(defun format-schedule (instrument rest)
  (etypecase instrument
    (number (str:substring 0 -1 (format nil "schedule ~d,~{~d,~}" instrument rest)))
    (string (str:substring 0 -1 (format nil "schedule ~s,~{~d,~}" instrument rest)))))

(defmethod schedule ((server csound) instrument &rest rest)
  (let ((msg (format-schedule instrument rest)))
    (send server msg)))

(defmethod readscore ((server csound) (score string))
  (let ((msg (format nil "ire readscore {{~%~a~%}}" score)))
    (send server msg)))