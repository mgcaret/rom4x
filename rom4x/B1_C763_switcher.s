.code
.include "iic.defs"
	.org gorst4x
	sta rombank	; gorst4x
	jmp reset4x	; in other bank jmp rstxrtn
	sta rombank	; gobt4x
	jmp boot4x
	sta rombank	; gobanner
	jmp $c784	; in other bank jsr appleii
	sta rombank
	rts		; not in other bank


