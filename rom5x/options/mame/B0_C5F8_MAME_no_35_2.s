; remove 3.5" functionality for MAME
; this bit removes protocol converter initialization
; so the 3.5" drive code is never called
.code
.include "iic+.defs"
          .org $c5f8
          rts

