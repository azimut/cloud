# cloud

Common Lisp helpers for CFFI interactions with CSOUND.

Depends on csound cffi [fork](https://github.com/azimut/csound)

## Usage
```
CLOUD> (start-csound (get-orchestra :xanadu))
CLOUD> (start-thread)
CLOUD> (make-play pluck  "i2" :p4 0 :keynum 60)
CLOUD> (play-pluck 70 2)
```

* merger.lisp: has helpers to merge 2 or more different orchestra objects into a new one.
* player.lisp: utilities that create the -play and -play-arp helpers from an orchestra
* server.lisp: start and stop server helpers
* queries.lisp: accessors for orchestra objects

## TODO
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

