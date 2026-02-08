.code
.psc02

; Bytes left with:
; - No JDM options: 32
; - romx: 2
; - xdrive: 13
; - both: 7

jdmcode = $300 ; where to put JDM device subroutines in RAM

.include "../macros/rompatch.macro"
.include "../macros/tmporg.macro"
.include "iic+.defs"
rompatch misc5x,306,"misc5x - ROM 5X miscellaneous"
        bra domenu		; Display menu
        bra dobann		; Display banner (title + By MG)
        bra gtkey		; get a key
        bra confirm		; ask SURE?
        bra ntitle		; display "Apple IIc +"
        .if .defined(jdm_romx) || .defined(jdm_xdrive)
        bra go_jdm
        .else
        rts             ; placeholder so table is the same in non-jdm builds
        rts
        .endif
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
        jmp swrts2		    ; jump to swrts2
.if .defined(jdm_romx) || .defined(jdm_xdrive)
; copy jdm code to RAM and execute
go_jdm: php
        ldy #jdm_len
:       lda jdm_addr,y
        sta jdmcode,y
        dey
        bpl :-
        plp                 ; get carry back
        jmp jdm             ; do xdrive or romx menus
.endif
; msg format
; A byte < $20 indicates high byte of address.
; Next byte must be low byte of address. Anything
; else are characters to display and will have their
; upper bit inverted before being written to the screen.
msg1 = *
        .byte $05,$06,"0 Mon"
        .ifdef jdm_romx
        .byte $05,$0F,"8 ROMX" ; no room for c/c+
        .else
        .byte "itor"
        .endif
        .byte $05,$86,"1 Reboot"
        .ifdef jdm_xdrive
        .byte $06,$06,"2 Conf Xdrive"
        .else
        .byte $06,$06,"2 Zero RAM Card"
        .endif
        .byte $06,$86,"3 Sys Diags"
        .ifdef jdm_xdrive
        .byte $07,$06,"4 Boot Xdrive"
        .else
        .byte $07,$06,"4 RAM Card Diags"
        .endif
        .byte $07,$86,"5 Boot 3.5/"
        .if .defined(jdm_romx) || .defined(jdm_xdrive)
        .byte "SP"
        .else
        .byte "SmartPort"
        .endif
        .byte $04,$2e,"6 Boot 5.25"
        .byte $04,$ae,"7 Accel"
        .if .defined(jdm_romx) || .defined(jdm_xdrive)
        .byte "."
        .else
        .byte "erator"
        .endif
        .if .defined(jdm_romx) || .defined(jdm_xdrive)
        .byte $07,$60
        .else
        .byte $07,$5f,"By "
        .endif
        .byte "M.G."
msg2:   .byte $07,$db,"ROM 5X "
        .include "build_date.inc"
        .byte $05,$ae,$00		; cursor pos in menu
msg3:   .byte $05,$b0,"SURE? ",$00
; metadata to identify build conditions
        .dword .time
        .word  .version
.if .defined(jdm_romx) || .defined(jdm_xdrive)
        jdm_addr = *
        tmporg $0300
        .proc jdm
        ; enter from aux ROM with carry set = ROMX menu, clear=Xdrive config
        sta $C028       ; main ROM
        bcs go_romx
        stz $C0C4       ; activate Xdrive ROM
        jmp $C987       ; launch menu
go_romx:
        bit $C0E0       ; hit IWM so accelerator does some synchronous cycles
        bit $FACA       ; ROMx activation sequence
        bit $FACA
        bit $FAFE
        jmp $DFD0       ; go to ROMxc+ menu
        .endproc
        endtmporg jdm_len
        .assert jdm_len < 128, error, "jdm_len too big"
.endif
endpatch
