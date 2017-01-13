#include "iic.defs"
.text
* = nbtfail
	ldx #msglen
lp1	lda bootmsg,x
	ora #$80
	sta $7d0+19-msglen/2,x
	dex
	bpl lp1
	lda #23		; last line
	sta cv
	lda #>(basic-1)
	pha
	lda #<(basic-1)
	pha
	jmp swrts2
bootmsg	.db "No bootable device."
msglen = * - bootmsg - 1

