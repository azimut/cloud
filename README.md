# cloud

Common Lisp helpers for CFFI interactions with CSOUND.

Depends on csound cffi [fork](https://github.com/azimut/csound)

## Usage
* server.lisp: start and stop server helpers
```
CLOUD> (setf *server* (make-instance 'internal))
CLOUD> (start *server*)
CLOUD> (send *server* (get-orchestra :xanadu))
```
* player.lisp: utilities that create the -play and -play-arp helpers from an orchestra
```
CLOUD> (make-play pluck  "i2" :p4 0 :keynum 60)
CLOUD> (play-pluck 70 2)
```
* merger.lisp: (experimental) has helpers to merge 2 or more different orchestra objects into a new one.
```
CLOUD> (sco (merge-orcs (get-orchestra :kkel) (get-orchestra :xanadu)))
"f1 0 8192 10 1
 f2 0 8192 11 1
 f3 0 8192 -12 20.0
 "
```
* queries.lisp: accessors for orchestra objects
```
CLOUD> (list-orcs)
(:DRUMKIT :BASS :ASYNTH :KKEL :TRAPPED :XANADU)
```
* udp.lisp: connect to an external csound server through UDP, use instead of internal

```
CLOUD> (setf *server* (make-instance 'udp))
CLOUD> (connect *server*)
????
```

## TODO
- Add guards/types? for the arguments to avoid float overflows or crashes
- Might be use structs/objects for instrument definitions? should be easier to write thigs for it???
- Support range for make-play arguments (clamp?
- Better server helpers...restart..query...object
- the ahead of time scheduler of scheduler is ... complicated to work with...I won't use (at or -arp) at the moment
- Clean that macro.
- There are ways to tell cffi to the allocation/conversion automatically
- Make an instrument library abstraction, so I can push an ORC with a custom set of instruments...nvm, tables are to thightly related to instruments combine or compose them won't be that easy...
- Make a parser for orcs, initially to get the signature of the insts, like if they need extra arguments or not. And create the classes accordingly
- Synths bring to the table the fact that I don't do much over time changes
- Then parse the instrument part too might be to get good default values
- But like baggers said "when you get a string in lisp is like it insults you"
- Aaaaaaand test ORCAsync
- CLOS object for the server: thread, status, reboot, load methods there
- I get a freeze state (? when doing (reset), might be due stop handling sigs
- Support "<" ">" "+" on scores...whatever that is...
- score debug helper to send messages
- debug more to show messages send
- seems like some instruments only work with determined global values of: sr,kr,ksmps,chnls...great!...
- overall support reload of instruments
- add panning parameters when converting from mono to stereo (or always)
- everything crashes with an invalid float point operation when I do weird
things with (some) params, appears to happen on the perform thread
- boy oh boy...might be this is why it never got popular...

## License

MIT
