; call RDCHAR, convert DEL to space
; for patching into GETLN1/NXTCHAR (at $FD75)
.code
.include "iic+.defs"
	.org $c4ee
	jsr $cced
	cmp #$ff
	bne :+
	lda #$88
:	rts

