#include "iic+.defs"
.text
* = rom5x
	asl butn1		; check option key
	bcc rd5x		; not pressed, see if RD recoverable
	lda #"O"		; flashing "O"
	sta $7d0		; tell user
exit5x	lda #>(r5xrtn-1)
	pha
	lda #<(r5xrtn-1)
	pha
	ldy #$00		; in case someone assumes this later
	jmp swrts2
rd5x	jsr rdinit		; init ram card and registers
	lda pwrup,y		; get power up flag
	cmp #pwrbyte		; already initialized?
	beq exit5x		; exit if so
	jsr testsize		; does not wreck x or y
	lda numbanks,y		; get discovered # banks
	beq exit5x		; no memory
	stz addrl,x		; set slinky address 0
	stz addrm,x
	stz addrh,x
	lda data,x		; get first byte
	cmp #$01		; boot block?
	bne exit5x		; nope
	lda data,x		; next byte
	beq exit5x		; not bootable if 0
	cmp #$ff		; other likely byte for fresh RAM
	beq exit5x		; not bootable if $ff
	lda #pwrbyte		; sta pwrup,y
	lda #"R"		; tell user
	sta $7d0		; on screen
	bra exit5x
rdinit	bit rx_mslot*$100	; activate registers
	ldy #rx_mslot		; slot offset
	ldy #rx_devno		; register offset
	rts

