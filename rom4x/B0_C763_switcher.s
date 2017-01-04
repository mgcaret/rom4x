#include "iic.defs"
.text
* = gorst4x
	sta rombank	; gorst4x
	jmp rst4xrtn	; in other bank jmp reset4x
	sta rombank	; gobt4x
	jmp bt4xrtn	; in other bank jmp boot4x
	sta rombank	; gobanner
	jsr banner	; in other bank jmp $c784 for now
	sta rombank	; return to other bank
	rts		; should never get here

