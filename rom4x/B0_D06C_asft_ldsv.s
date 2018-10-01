
.pc02
XM_LOAD = $C9A1
XM_SAVE = $C9A4
.include "iic.defs"
        .org $D06C
.ifdef EN_XMODEM
        .addr XM_LOAD-1
        .addr XM_SAVE-1
.endif