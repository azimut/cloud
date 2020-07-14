(in-package #:cloud)

(defclass internal (csound)
  ((pointer :accessor pointer :initform nil); unbound?
   (options :accessor options)))

(defmethod (setf options) :before (new-options (server internal))
  (check-type new-options list))
(defmethod (setf options) (new-options (server internal))
  (loop :for option :in new-options
        :when (stringp option)
        :do (csound:set-option (pointer server) option)))

(cffi:defcallback newthread :int ((data :pointer))
  (csound:perform data))

(defmethod start :around ((server internal))
  (unless (pointer server)
    (call-next-method)))
(defmethod start ((server internal))
  (csound:initialize 3); Headless
  (setf (pointer server) (csound:create (cffi:null-pointer)))
  (setf (options server) *csound-options*)
  (csound:start (pointer server)))
(defmethod start :after ((server internal))
  (csound:create-thread (cffi:get-callback 'newthread) (pointer server)))

(defmethod stop :around ((server internal))
  (when (pointer server)
    (call-next-method)))
(defmethod stop ((server internal))
  (csound:stop (pointer server))
  (csound:destroy (pointer server)))

(defmethod chnk ((server internal) (channel string))
  (csound:compile-orc (pointer server) (format nil "chn_k ~s, 1" channel)))
(defmethod chnset ((server internal) (channel string) (value double-float))
  (csound:set-control-channel (pointer server) channel value))

(defmethod readscore ((server internal) (score string))
  (csound:read-score (pointer server) score))

(defmethod send ((server internal) (orchestra string))
  (csound:compile-orc (pointer server) orchestra))
(defmethod send ((server internal) (orchestra orc))
  (with-slots (orc sco globals) orchestra
    (send      server (stich globals orc))
    (readscore server (stich sco))))
