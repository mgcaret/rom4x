#include "iic+.defs"
.text
* = $fb3c ; ~165 bytes free here
	cmp #$a9		; reset patch
	bne chk2
	jmp reset5x
chk2:	cmp #$ea		; boot patch
	bne chk3
	jmp boot5x
chk3:	cmp #$40		; beep
	bne dowait
; "classic air raid beep"
; inspired by http://quinndunki.com/blondihacks/?p=2471
	jsr $fcb5		; (new) WAIT for .1 sec delay
	ldy #$c0
obell2:	lda #$0c
	jsr owait		; old wait for correct sound
	lda $c030
	dey
	bne obell2
	bra dexit		; back to caller
dowait:	jsr $fcb5		; do delay if anything else
	lda #>($fbe2-1)		; return to other bank here (in BELL1)
	pha			; by pushing address onto
	lda #<($fbe2-1)		; the stack
	pha
	lda #$00		; in case someone assumes this
dexit:	jmp swrts2		; back to other bank
; old wait - no ACIA access to enforce delay at
; accelerated speeds, speaker delay tkes care of it
; when we do the old beep
owait:	sec
owait2:	pha
owait3: sbc #$01
	bne owait3
	pla
	sbc #$01
	bne owait2
	rts
