.code
.psc02
.include "iic+.defs"
        .org misc5x ; max 306 bytes
        bra domenu		; Display menu
        bra dobann		; Display banner (title + By MG)
        bra gtkey		; get a key
        bra confirm		; ask SURE?
        bra ntitle		; display "Apple IIc +"
dobann:	jsr ntitle
        ldx #(msg2-msg1)	; msg display entry point
        jmp disp
domenu:	jsr ntitle		;  "Apple ||c +"
        ldx #$00		; menu start
        jsr disp		; show it
        rts
gtkey:	lda #$60
        sta ($0),y		; cursor
        sta kbdstrb		; clr keyboard
kbdin:	lda kbd			; get key
        bpl kbdin
        sta kbdstrb		; clear keyboard
        sta ($0),y		; put it on screen
        rts
; display message, input x = message start relative to msg1
disp:	  ldy #$0			; needs to be zero
disp0:	lda msg1,x		; get message byte
        bne disp1		; proceed if nonzero
        rts			; exit if 0
disp1:	inx			; next byte either way
        cmp #$20		; ' '
        bcc disp2		; start of ptr if < 20 
        eor #$80		; invert high bit
        sta ($0),y		; write to mem
        inc $0			; inc address low byte
        bra disp0		; back to the beginning
disp2:	sta $1			; write address high
        lda msg1,x		; get it
        sta $0			; write address low
        inx			; set next msg byte
        bra disp0		; back to the beginning
confirm:
        pha
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
; we push the address of swrts/swrts2 onto the stack
; and then the address of the title routine
; we then jump to swrts2 which switches banks and RTS to
; display "Apple IIc +", which then RTS to swrts, which
; switches banks back to here and RTS to our caller.
ntitle:	lda #>(swrts2-1)	; put return addr of swrts/swrts2 on stack
        pha
        lda #<(swrts2-1)
        pha
        lda #>(banner-1)	; put addr of the Title routine on the stack
        pha
        lda #<(banner-1)
        pha
        jmp swrts2		; jump to swrts2
; msg format
; A byte < $20 indicates high byte of address.
; Next byte must be low byte of address. Anything
; else are characters to display and will have their
; upper bit inverted before being written to the screen.
msg1 = *
        .byte $05,$06,"0 Monitor"
        .byte $05,$86,"1 Reboot"
        .byte $06,$06,"2 Zero RAM Card"
        .byte $06,$86,"3 Sys Diags"
        .byte $07,$06,"4 RAM Card Diags"
        .byte $07,$86,"5 Boot 3.5/SmartPort"
        .byte $04,$2e,"6 Boot 5.25"
        .byte $04,$ae,"7 Accelerator"
        .byte $07,$5f,"By M.G."
msg2:   .byte $07,$db,"ROM 5X 11/09/17"
        .byte $05,$ae,$00		; cursor pos in menu
msg3:   .byte $05,$b0,"SURE? ",$00
; metadata to identify build conditions
        .dword .time
        .word  .version
