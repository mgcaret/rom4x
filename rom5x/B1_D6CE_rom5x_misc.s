#include "iic+.defs"
.text
* = misc5x ; max 306 bytes
	bra domenu
	bra dobann
	bra gtkey
	bra confirm
dobann	jsr ntitle
	ldx #(msg2-msg1)	; msg display entry point
	jmp disp
domenu	jsr ntitle		;  "Apple ||c +"
	ldx #$00		; menu start
	jsr disp		; show it
	rts
gtkey	lda #$60
	sta ($0),y		; cursor
	sta kbdstrb		; clr keyboard
kbdin	lda kbd			; get key
	bpl kbdin
	sta kbdstrb		; clear keyboard
	sta ($0),y		; put it on screen
	rts
; display message, input x = message start relative to msg1
disp	stz $0			; load some safe defaults
	lda #$40
	sta $1
	ldy #$0			; needs to be zero
disp0	lda msg1,x		; get message byte
	bne disp1		; proceed if nonzero
	rts			; exit if 0
disp1	inx			; next byte either way
	cmp #$20		; ' '
	bcc disp2		; start of ptr if < 20 
	eor #$80		; invert high bit
	sta ($0),y		; write to mem
	inc $0			; inc address low byte
	bra disp0		; back to the beginning
disp2	sta $1			; write address high
	lda msg1,x		; get it
	sta $0			; write address low
	inx			; set next msg byte
	bra disp0		; back to the beginning
confirm	pha
	ldx #(msg3-msg1)	; ask confirm
	jsr disp
	jsr gtkey
	plx
	ora #$20		; to lower
	cmp #$f9		; "y"
	php
	txa
	plp
	rts
; display "Apple IIc +" in a convoluted manner
; ultimately, the rts instruction here "rts" to swrts2
; which switches banks and "rts" to the title/banner firmware call
; which then "rts" to swrts (same addr as swrts2, but main bank)
; which then actually rts to our caller
ntitle	lda #>(swrts2-1)	; put return addr of swrts2 on stack
	pha
	lda #<(swrts2-1)
	pha
	lda #>(banner-1)
	pha
	lda #<(banner-1)
	pha
	lda #>(swrts2-1)
	pha
	lda #<(swrts2-1)
	pha
	rts			; jump to swrts2
; msg format
; A byte < $20 indicates high byte of address.
; Next byte must be low byte of address. Anything
; else are characters to display and will have their
; upper bit inverted before being written to the screen.
msg1 = *
	.db $05,$06,"0 Monitor"
	.db $05,$86,"1 Reboot"
	.db $06,$06,"2 Zero RAM Card"
	.db $06,$86,"3 Sys Diags"
	.db $07,$06,"4 RAM Card Diags"
	.db $07,$86,"5 Boot 3.5/SmartPort"
	.db $04,$2e,"6 Boot 5.25"
;	.db $04,$ae,"7 Accelerator"
	.db $07,$5f,"By M.G."
msg2	.db $07,$db,"ROM 5X 02/08/17"
	.db $05,$ae,$00		; cursor pos in menu
msg3	.db $05,$b0,"SURE? ",$00

