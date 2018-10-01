.pc02
.include "iic.defs"
.code
    .org $FF73
.ifdef EN_XMODEM
    jsr $CFE5     ; R/W patch
.endif