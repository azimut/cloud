(in-package #:cloud)

;; XANADU

(make-play plucke "i1" :p4 0 :keynum 60)
(make-play pluck  "i2" :p4 0 :keynum 60)
(make-play newfm  "i3" :p4 0 :keynum 60 :llimit .2 :rlimit 2.0)

;; TRAPPED

(make-play cooper "i6" :p4 .81 :sweeps 3000 :sweepe 17 :band 10 :rev .6 :amp 1.6)
(make-play red    "i8" :amp 4 :swp 20 :eswp 8000 :band 590 :rand1 2 :rand2 9.9 :rev .6)
(make-play swirl "i99" :pan 2)

(make-play ivory  "i1" :p4 0 :keynum 60 :amp 200 :vib .001 :glis 17.8 :drop .99)
(make-play blue   "i2" :p4 0 :keynum 60 :amp 600 :reverb .6 :lfo 23 :harm 10 :sweep .52)
(make-play violet "i3" :p4 0 :keynum 60 :amp 800 :reverb .8 :rand 57)
(make-play black  "i4" :p4 0 :keynum 60 :amp 800 :swp 4600 :eswp 6500 :band 33 :rev 0.6)
(make-play green  "i5" :p4 0 :keynum 60 :amp 900 :rev .2 :pan .1 :carr 3 :modf 10 :modi 12 :rand 27)
(make-play pewter "i7" :amp 1000 :keynum 60 :bphase .2 :ephase .7 :oamp .6 :oscf 2 :oscm 3 :rev .12)
(make-play sand   "i9" :delay .2 :keynum 60 :amp 500 :rev .2 :ramp 6.2 :rfreq 320)
(make-play taupe  "i10" :p4 0 :keynum 60 :amp 500 :rev .8 :ramp 5 :rfreq 223)
(make-play rust   "i11" :delay 0 :keynum 60 :amp 1200 :rev .2)
(make-play teal   "i12" :p4 0 :keynum 60 :amp 1000 :swp 100 :pswp 7000 :band 16 :rev .2)
(make-play foam   "i13" :p4 0 :keynum 60 :amp 1000 :vib 40 :glis 7)

;; DRUMKIT

(make-play bass "i1"
           :amp 10000  :wave 1
           :pulse 8 :env 10 :rhy 30 :keynum 60 :gliss 20 :p1 .1)

(make-play hihat "i2"
           :amp 10000 :pulse 8 :rhy 32
           :env1 12 :env2 11 :pan1 .7 :pan2 .2)

(make-play snare "i3"
           :amp 10000 :pulse 8
           :env1 13 :env2 14 :rhy 33 :pan1 .3 :pan2 .2)

(make-play crash "i4"
           :amp 2500 :pulse .25 :rhy 34 :env1 12 :env2 15
           :pan1 .2 :pan2 .2 :keynum 80)

;; BASS

(make-play bass "i1"
           :fco1 .1  :fco2 .3
           :res1 .2  :res2 .2
           :env1 .1  :env2 .4
           :dec1 .05 :dec2 .8
           :acc1 0   :acc2 0
           :bars 120
           :amp .2
           :keynum 60)

;; ASYNTH

(make-play asynth "i1.1"
           :amp .5
           :keynum 60
           :semi 1
           :fine 1
           :vcf1 1000 :vcf2 200
           :rez 10
           :wav1 2 :wav2 2
           :wave 2
           :rate1 .25 :rate2 .3
           :ring .75)
