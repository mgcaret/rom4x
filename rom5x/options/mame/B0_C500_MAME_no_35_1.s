; remove 3.5" functionality for MAME
; this bit causes slot 5 boot to go to do 6 boot instead
; and also overwrites the firmware protocol bits to not
; identify as a block device.
.code
.include "iic+.defs"
rompatch $c500,0,"MAME_no_35_1"
          ldx #$00
          lda #$c6
          stx $00
          sta $01
          jmp ($00)
endpatch
