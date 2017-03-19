.code
.psc02
.include "iic+.defs"
	.org reset5x ; max 157 bytes
	stz power2 + rx_mslot	; action = normal reset
	lda #>(rst5xrtn-1)	; common case
	pha
	lda #<(rst5xrtn-1)
	pha			; note that this stays on stack
	asl butn1		; option (closed apple)
	bcs ckdiag
exitrst: jmp swrts2
; check to see if cmd_option (both apples) are down
ckdiag:	bit butn0		; command (open apple)
	bmi exitrst		; return to RESET.X
; present menu because only closed apple is down
menu:	jsr menu5x		; display menu
	jsr gkey5x
	cmp #$b0		; "0"
	bne ckkey1
	ldx #$ff		; reset stack
	txs
	lda #>(monitor-1)	; monitor entry on stack
	pha
	lda #<(monitor-1)
	pha
	jmp swrts2		; rts to enter monitor
ckkey1:	cmp #$b2		; "2"
	beq doconf
	cmp #$b4		; "4"
	bne ckkey2
doconf:	jsr conf5x
	bne menu		; go back to menu4x
ckkey2:	sec
	sbc #$b0		; ascii->number
	bmi menu		; < 0 not valid
	cmp #$07		; we will use 7 for accelerator later
	bpl menu		; > 7 not valid
	sta power2 + rx_mslot	; for boot5x
	stz softev + 1		; deinit coldstart
	stz pwerdup		; ditto
	bra exitrst

