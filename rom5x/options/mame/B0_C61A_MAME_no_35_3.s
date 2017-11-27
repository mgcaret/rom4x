; remove 3.5" functionality for MAME
; this bit removes some 3.5" cruft added to the 5.25" boot code
.code
.include "iic+.defs"
          .org $c61a
          lda $c089,x
