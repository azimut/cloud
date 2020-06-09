(in-package #:cloud)

(defparameter *roomie-listener*
  "gklisxSmooth, gklisySmooth, gkliszSmooth, gklisdirSmooth init 0
   instr 1001
     ibcount active 1001
     if (ibcount == 1) then
       klisx, klisy, klisz, klisdir init 0
       klisx          chnget \"lposx\"
       klisy          chnget \"lposy\"
       klisz          chnget \"lposz\"
       klisdir        chnget \"ldir\"
       gklisxSmooth   port   klisx,   .025
       gklisySmooth   port   klisy,   .025
       gkliszSmooth   port   klisz,   .025
       gklisdirSmooth port   klisdir, .025
     else
       turnoff
     endif
   endin"
  "Instrument to constantly smooth listener params.")

(defclass listener ()
  ((server :initform *server*
           :initarg  :server
           :reader server)
   (pos    :initform (v! 0 0 0)
           :accessor pos)))

(defmethod initialize-instance :before ((obj listener) &key)
  (check-type (slot-value obj 'server) csound))

(defmethod initialize-instance :after ((obj listener) &key)
  (with-slots (server) obj
    (chnk server "lposx")
    (chnk server "lposy")
    (chnk server "lposz")
    (chnk server "ldir")
    (send server *roomie-listener*)
    (schedule server 1001 0 -1)))

(defmethod (setf pos) :after (new-pos (obj listener))
  (chnset (server obj) "lposx" (x new-pos))
  (chnset (server obj) "lposy" (y new-pos))
  (chnset (server obj) "lposz" (z new-pos)))
