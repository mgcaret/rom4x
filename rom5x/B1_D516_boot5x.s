#include "iic+.defs"
.text
* = boot5x ; 234 bytes available, code assembles to 231 when 
	   ; next line uncommented
;	jsr ntitle		; TODO "Apple IIc +"
	jsr rdrecov		; try to recover ramdisk
	lda power2 + rx_mslot	; get action saved by reset5x
	beq boot4		; if zero, continue boot
	jsr bann5x		; display ROM 5X footer
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
	jsr rdinit		; get x and y loaded
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
btc5	cmp #$05		; boot smartport
	beq boot5
	; fall through if none of the above
boot4	lda #rx_mslot		; boot slot 4
	bra bootsl
boot5	lda #$c5		; boot slot 5
	bra bootsl
boot6	lda #$c6		; boot slot 6
bootsl	ldx #$00		; low byte of slot
bootadr	stx $0			; store address
	sta $1			; return to bank 0 does jmp (0)
endbt4x lda #>(bt5xrtn-1)
	pha
	lda #<(bt5xrtn-1)
	pha
	lda $1
	jmp swrts2
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
	lda data,x		; start check for bootable ramdisk
	cmp #$01
	bne recovdn		; not bootable
	lda data,x		; next byte should be nonzero and not $ff
	beq recovdn		; not bootable
	cmp #$ff
	beq recovdn		; not bootable
	lda #pwrbyte
	sta pwrup,y		; set power byte
	lda #"R"		; tell user
	sta $7d0		; on screen
recovdn	rts
; zero ram card space
rdclear	jsr rdinit		; init ramcard
	jsr testsize		; get size
	lda numbanks,y		; # of 64Ks to write
	beq clrdone		; no memory
	lda #$c0		; 'A' - 1
	sta $400		; upper left corner
	stz addrl,x		; slinky address 0
	stz addrm,x
	stz addrh,x
clbnklp	inc $400		; poor mans progress meter
	ldy #$00
cl64klp	ldx #$00		; loop for all pages in bank
cl256lp txa			; loop for all bytes in page
	ldx #rx_devno
	stz data,x		; write a zero to card
	tax
	dex
	bne cl256lp		; 256 byte loop
	dey
	bne cl64klp		; 64K loop
	ldx #rx_mslot
	dec numbanks,x
	bne clbnklp		; if more banks
clrdone	ldx #rx_mslot
	stz pwrup,x		; zero powerup byte
	lda #$a0		; ' '
	sta $400		; clear progress
	rts
rdinit	bit rx_mslot*$100	; activate registers
	ldy #rx_mslot		; slot offset
	ldx #rx_devno		; register offset
	rts
; next is snippet of code to boot external 5.25
bootext	lda #$e0
	ldy #$01
	ldx #$60
	jmp $c60b
bt4xend = *


