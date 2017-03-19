.psc02
.code
.include "iic.defs"
	.org $c552
	jsr setnorm
	jsr init
	bra cbtfail
	.res coma-*,$ea
	bra coma		; Make sure coma routine exists
	.byte 0			; rom4x present
cbtfail:	jsr setvid
	jsr setkbd
	lda #>(nbtfail-1)
	pha
	lda #<(nbtfail-1)
	pha
	jmp swrts2
	
