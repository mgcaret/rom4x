#include "iic+.defs"
.text
* = $fbe2 ; ~29 bytes free here
	cmp #$a9		; reset patch
	bne chk2
	jmp reset5x
chk2:	cmp #$ea		; boot patch
	bne dowait
	jmp boot5x
dowait:	jsr $fcb5		; do delay if anything else
	lda #>($fbe2-1)
	pha
	lda #<($fbe2-1)
	pha
	lda #$00		; in case someone assumes this
	jmp swrts2
	; 28 bytes, will have to move if we get bigger
