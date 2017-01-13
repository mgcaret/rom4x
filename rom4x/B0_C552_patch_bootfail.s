#include "iic.defs"

.text
* = $c552
	jsr setnorm
	jsr init
	bra cbtfail
	.dsb coma-*,$ea
	bra coma		; Make sure coma routine exists
	.db 0			; rom4x present
cbtfail	jsr setvid
	jsr setkbd
	lda #>(nbtfail-1)
	pha
	lda #<(nbtfail-1)
	pha
	jmp swrts2
	
