; Monitor R and W command handler for XModem
GETNUM = $FFA7
DISPATCH = $C7FC

.pc02

.include "iic.defs"
.code
        .org $CFE5 ; 20 bytes here
.ifdef EN_XMODEM
lp:     jsr  GETNUM
        sta  $00
        cmp  #$EB       ; 'R'
        beq :+
        cmp  #$F0       ; 'W'
        beq :+
        rts
:       jsr DISPATCH
        bra lp
.endif
