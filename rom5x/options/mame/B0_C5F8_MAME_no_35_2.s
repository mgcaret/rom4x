; remove 3.5" functionality for MAME
; this bit removes protocol converter initialization
; so the 3.5" drive code is never called
.code
.include "iic+.defs"
rompatch $c5f8,0,"MAME_no_35_2"
          rts
endpatch
