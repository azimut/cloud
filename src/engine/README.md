Ideas took from code at: [Interfacing Csound and Unity](http://csoundjournal.com/issue19/InterfacingCsoundUnity.html)

# Example
In your project
``` common-lisp
(setf cloud::*server* (make-instance 'cloud::udp))
(cloud::connect cloud::*server*)

(defun cloud:get-listener-pos ()
  (pos *currentcamera*))
(defun cloud:get-listener-rot ()
  (rot *currentcamera*))
```
## For roomie

``` common-lisp
(cloud::schedule cloud::*server* 2 0 120 1 30 0 .5)

(defmethod update :after ((actor sound-source) dt)
  (setf (pos actor) (v! 0 4 0))
  (cloud::upload-source actor)
  (setf (cloud::pos actor) (copy-seq (pos actor))))
```


# TODO
- LinePath for oclussion
- LinePath for distance attenuation of reverb
