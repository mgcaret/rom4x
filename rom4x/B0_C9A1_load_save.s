.pc02
DISPATCH = $C7FC

.include "iic.defs"
.code
        .org $C9A1      ; 9 bytes here
.ifdef EN_XMODEM
load:   lda #$03
        .byte $2C   ; BIT abs
save:   lda #$02
        jmp DISPATCH
.endif
