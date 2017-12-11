; This is the dispatch routine to call the primary ROM 5X
; functions of intercepting RESET and the boot process.
; If one enters at $CFF9, the command $A9 is loaded and
; we go to the BELL1 hijack.  If entering at $CFFA, we
; load the command $EA and proceed the same way.
; thus we get two dispatch codes in 6 bytes.

.include "iic+.defs"
.code
	.org $cff9 ; 7 bytes available here, but don't count on $CFFF
	lda #$a9	; lda opcode
	nop		; jmp/jsr $cffa does lda #$ea
	jmp $c7fc	; jump to 5X dispatcher
; total 6 bytes.

