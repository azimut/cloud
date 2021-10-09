(in-package #:cloud)

(defclass listener () ())

(defvar *roomie-listener*
  "gklisxSmooth, gklisySmooth, gkliszSmooth, gklisdirSmooth init 0
   instr 1001
     ibcount active 1001
     if (ibcount == 1) then
       klisx, klisy, klisz, klisdir init 0
       klisx          chnget \"lisx\"
       klisy          chnget \"lisy\"
       klisz          chnget \"lisz\"
       klisdir        chnget \"lisdir\"
       gklisxSmooth   port   klisx,   .025
       gklisySmooth   port   klisy,   .025
       gkliszSmooth   port   klisz,   .025
       gklisdirSmooth port   klisdir, .025
     else
       turnoff
     endif
   endin"
  "Instrument to constantly smooth listener params. Audio glitches otherwise.")

(defmethod initialize-instance :after ((obj listener) &key)
  (init-channel "lisx" 0.0)
  (init-channel "lisy" 0.0)
  (init-channel "lisz" 0.0)
  (init-channel "lisdir"  0.0)
  (send *server* *roomie-listener*)
  (schedule *server* 1001 0 -1))
