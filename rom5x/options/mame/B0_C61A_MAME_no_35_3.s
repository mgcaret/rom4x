; remove 3.5" functionality for MAME
; this bit removes some 3.5" cruft added to the 5.25" boot code
.code
.include "iic+.defs"
rompatch $c61a,0,"MAME_no_35_3"
          lda $c089,x
endpatch
