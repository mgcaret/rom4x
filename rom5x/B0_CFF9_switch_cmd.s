#include "iic+.defs"
.text
* = $cff9 ; 7 bytes available here
	lda #$a9	; lda opcode
	nop		; jmp/jsr $cffa does lda #$ea
	jmp $fbdf	; jump to bell1 hijack
; total 6 bytes.

