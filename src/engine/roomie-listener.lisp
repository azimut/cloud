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
  "Instrument to constantly smooth listener params. Audio glitches otherwise.")

(defclass listener ()
  ())

(defmethod initialize-instance :after ((obj listener) &key)
  (init-channel "lposx" 0.0)
  (init-channel "lposy" 0.0)
  (init-channel "lposz" 0.0)
  (init-channel "ldir"  0.0)
  (send *server* *roomie-listener*)
  (schedule *server* 1001 0 -1))
