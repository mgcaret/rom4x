#include "iic.defs"
.text
* = reset4x
	stz power2 + rx_mslot	; action = normal boot
	asl butn1		; closed apple
	bcs ckdiag
exitrst jmp gorst4x		; return to RESET.X
; check to see if both apples are down
ckdiag	bit butn0		; open apple
	bmi exitrst		; return to RESET.X
; present menu because only closed apple is down
menu4x	jsr gobanner		; "Apple //c"
	ldx #$00		; menu start
	jsr disp		; show it
	jsr gtkey
	cmp #$b0		; "0"
	bne ckkey1
	ldx #$ff		; reset stack
	txs
	lda #>(monitor-1)	; monitor entry ons tack
	pha
	lda #<(monitor-1)
	pha
	jmp swrts2		; rts to enter monitor
ckkey1	cmp #$b2		; "2"
	beq doconf
	cmp #$b4		; "4"
	bne ckkey2
doconf	jsr confirm
	bne menu4x		; go back to menu4x
ckkey2	sec
	sbc #$b0		; ascii->number
	bmi menu4x		; < 0 not valid
	cmp #$08
	bpl menu4x		; > 7 not valid
	sta power2 + rx_mslot	; for boot4x
	stz softev + 1		; deinit coldstart
	stz pwerdup		; ditto
	bra exitrst
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
; msg format
; A byte < $20 indicates high byte of address.
; Next byte must be low byte of address. Anything
; else are characters to display and will have their
; upper bit inverted before being written to the screen.
msg1 = *
	.db $05,$06,"0 Monitor"
	.db $05,$86,"1 Reboot"
	.db $06,$06,"2 Zero RAM Card and Reboot"
	.db $06,$86,"3 Diagnostics"
	.db $07,$06,"4 RAM Card Diagnostics"
	.db $07,$86,"5 Boot SmartPort"
	.db $04,$2e,"6 Boot Int. 5.25"
	.db $04,$ae,"7 Boot Ext. 5.25"
	.db $07,$5f,"By M.G."
msg2	.db $07,$db,"ROM 4X 01/01/17"
	.db $05,$ae,$00		; cursor pos in menu
msg3	.db $05,$b0,"SURE? ",$00
	.dsb boot4x - *, 0
* = boot4x
	jsr gobanner		; "Apple //c"
	jsr rdrecov		; try to recover ramdisk
	lda power2 + rx_mslot	; get action saved by reset4x
	beq boot4		; if zero, continue boot
	ldx #(msg2-msg1)	; short banner offset
	jsr disp		; display it
	lda power2 + rx_mslot	; boot selection
btc2	cmp #$02		; clear ramcard
	bne btc3
	jsr rdclear		; do clear
	bra boot4
btc3	cmp #$03		; Diags
	bne btc4
	jmp $c7c4
btc4	cmp #$04		; RX diags
	bne btc5
	ldx #$ff
	txs			; reset stack
	ldy #rx_mslot		; diag routine needs
	ldx #rx_devno		; ditto
	stx sl_devno		; diags need this
	jsr testsize		; compute card size
	lda #>(monitor-1)	; load "return" address
	pha			; into stack so that we
	lda #<(monitor-1)	; exit card test into
	pha			; the monitor
	lda numbanks,y		; get the card size in banks
	bne dordiag		; do diag if memory present
	jmp swrts2		; otherwise jump to monitor
dordiag	jmp $db3a		; diags
	;bra boot4
btc5	cmp #$05		; boot smartport
	beq boot5
btc6	cmp #$06		; boot int drive
	beq boot6
btc7	cmp #$07		; boot ext drive
	bne boot4		; none of the above
	; copy small routine to $300 to boot
	; external 5.25
	ldy #(bt4xend-bootext+1)
btc7lp	lda bootext,y
	sta $300,y
	dey
	bpl btc7lp
	lda #$03		; copy done
	ldx #$00
	bra bootadr
boot4	lda #rx_mslot		; boot slot 4
	bra bootsl
boot5	lda #$c5		; boot slot 5
	bra bootsl
boot6	lda #$c6		; boot slot 6
bootsl	ldx #$00		; low byte of slot
bootadr	stx $0			; store address
	sta $1			; return to bank 0 does jmp (0)
endbt4x jmp gobt4x		; continue boot
rdrecov	jsr rdinit		; init ramcard
	lda pwrup,y		; get power up flag
	cmp #pwrbyte		; already initialized?
	beq recovdn		; exit if initialized
	jsr testsize		; does not wreck x or y
	lda numbanks,y		; get discovered # banks
	beq recovdn		; no mem
	stz addrl,x		; set slinky address 0
	stz addrm,x
	stz addrh,x
	lda data,x		; start compare to ProDOS boot block
	cmp #$01
	bne recovdn		; not ProDOS
	lda data,x
	cmp #$38
	bne recovdn		; not ProDOS
	lda data,x
	cmp #$b0
	bne recovdn		; not ProDOS
	lda #pwrbyte
	sta pwrup,y		; set power byte
	lda "R"			; tell user
	sta $7d0		; on screen
recovdn	rts
; zero ram card space
rdclear	jsr rdinit		; init ramcard
	jsr testsize		; get size
	lda #$c0		; 'A' - 1
	sta $400		; upper left corner
	lda #$00		; we are going to write this everywhere
	sta addrl,x		; slinky address 0
	sta addrm,x
	sta addrh,x
	ldx numbanks,y		; # of 64Ks to write
	beq clrdone		; no memory
clbnklp	phx			; wish the 65xx had more registers
	inc $400		; poor mans progress meter
	ldy #$00
cl64klp	ldx #$00		; loop for all pages in bank
cl256lp phx			; loop for all bytes in page
	ldx #rx_devno		; more registers, please!
	sta data,x		; write a zero to card
	plx
	dex
	bne cl256lp
	dey
	bne cl64klp
	plx
	dex
	beq clrdone
	bra clbnklp
clrdone	ldy #rx_mslot
	sta pwrup,y		; zero screen holes
	sta numbanks,y
	lda #$a0		; ' '
	sta $400		; clear progress
	rts
rdinit	bit rx_mslot *$100	; activate registers
	ldy #rx_mslot		; slot offset
	ldx #rx_devno		; register offset
	rts
; next is snippet of code to boot external 5.25
bootext	sei
	lda #$e0
	ldy #$01
	ldx #$60
	jmp $c60b
bt4xend = *


