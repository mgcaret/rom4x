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
	lda #>($fbe2-1)		; return to other bank here
	pha			; by pushing address onto
	lda #<($fbe2-1)		; the stack
	pha
	lda #$00		; in case someone assumes this
	jmp swrts2		; back to other bank
	; 28 bytes, will have to move if we get bigger
