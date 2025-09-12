.psc02
.code
.include "iic.defs"
.include "../macros/tmporg.macro"

detcode   = $300 ; where to put dectect subroutines in RAM

; to enable/disable XModem, see EN_XMODEM in iic.defs

          .org rom4x_disp
.proc     dispatch
          cmp #$a9                  ; reset patch
          beq reset4x
          cmp #$ea                  ; boot patch
          bne :+
          jmp boot4x
:         cmp #$01                  ; $01 = new boot fail routine
          bne :+
          jmp nbtfail
.ifdef EN_XMODEM
          ; XModem functions
:         cmp #$02                  ; $02 = AppleSoft SAVE
          bne :+
          jmp asftsave
:         cmp #$03                  ; $03 = AppleSoft LOAD
          bne :+
          jmp asftload
:         cmp #$F0                  ; $F0 = monitor W(rite)
          bne :+
          jmp monwrite
:         cmp #$EB                  ; $EB = monitor R(ead)
          bne :+
          jmp monread
.endif
:         sta $00                   ; for debug, why did we get here?
gomon:    lda #>(monitor-1)         ; go to the system monitor
          pha
          lda #<(monitor-1)
          pha
          jmp swrts2                ; jump to monitor
.endproc

; next is snippet of code to boot external 5.25, must be at $800
.proc     bootext
          lda #$e0
          ldy #$01                    ; unit #
          ldx #$60                    ; slot #
          jmp $c60b                   ; jump into Disk II code
.endproc

.proc     reset4x
          stz power2 + rx_mslot     ; clear boot selection (0=normal boot)
          asl butn1                 ; closed apple
          bcs ckdiag                ; check open apple next, or fall through to normal reset
exitrst:  lda #>(rst4xrtn-1)
          pha
          lda #<(rst4xrtn-1)
          pha
          jmp swrts2
; check to see if both apples are down
ckdiag:   bit butn0                 ; open apple
          bmi exitrst               ; return to RESET.X
          clc
          jsr jdmicro               ; detect JD Micro stuff
; present menu because only closed apple is down
menu4x:   jsr ntitle                ; "Apple //c"
          bit jdm                   ; check for ROMxc+
          bpl :+                    ; nope
          ldx #(msg4-msg1)          ; yes, display menu item #8
          jsr disp
:         ldx #(msg1-msg1)          ; menu start, better be 0
          jsr disp                  ; show it
          ldx #(msg1a-msg1)         ; anticipate no xDrive
          bit jdm                   ; check for xDrive
          bvc :+                    ; if no xDrive...
          ldx #(msg1b-msg1)         ; have xDrive, adjust menu
:         jsr disp
          jsr gtkey
          cmp #$b0                  ; "0"
          bne ckkey1
          ldx #$ff                  ; reset stack
          txs
          bra dispatch::gomon
ckkey1:   bit jdm
          bvc :+                    ; no xDrive, prompt user
          cmp #$b2                  ; "2" - ignore it here
          beq menu4x                ; redisplay menu
          bra ckkey2
:         cmp #$b2                  ; "2"
          beq doconf
          cmp #$b4                  ; "4"
          bne ckkey2
doconf:   jsr confirm
          bne menu4x                ; go back to menu4x
ckkey2:   sec
          sbc #$b0                  ; ascii->number
          bmi menu4x                ; < 0 not valid
          bit jdm                   ; check for ROMxc+
          bmi :+                    ; yes, we accept 0-8
          cmp #$08                  ; otherwise, accept 0-7
          bcs menu4x                ; >= 8 not valid
:         cmp #$09                  ; 9 or more?
          bcs menu4x                ; >= 9 not valid either
          cmp #$08                  ; is it exactly 8?
          beq romxc                 ; is 8, do ROMxc+ menu
          sta power2 + rx_mslot     ; for boot4x
          stz softev + 1            ; deinit coldstart
          stz pwerdup               ; ditto
          bra exitrst
romxc:    sec
          jsr jdmicro               ; launch ROMxc+ menu
          bra menu4x                ; if we get here, it didn't work, go display menu
.endproc

.proc     gtkey
gtkey:    lda #$60
          sta ($0),y                ; cursor
          sta kbdstrb               ; clr keyboard
kbdin:    lda kbd                   ; get key
          bpl kbdin
          sta kbdstrb               ; clear keyboard
          sta ($0),y                ; put it on screen
          rts  
.endproc

; display message, input x = message start relative to msg1
.proc     disp
disp:     stz $0                    ; load some safe defaults
          lda #$04
          sta $1
          ldy #$0                   ; needs to be zero
disp0:    lda msg1,x                ; get message byte
          bne disp1                 ; proceed if nonzero
          rts                       ; exit if 0
disp1:    inx                       ; next byte either way
          cmp #$20                  ; ' '
          bcc disp2                 ; start of ptr if < 20 
          cmp #$FF                  ; "GOTO"?
          bne :+                    ; nope
          lda msg1,x                ; get new X
          tax
          bra disp0                 ; move on
:         eor #$80                  ; invert high bit
          sta ($0),y                ; write to mem
          inc $0                    ; inc address low byte
          bra disp0                 ; back to the beginning
disp2:    sta $1                    ; write address high
          lda msg1,x                ; get it
          sta $0                    ; write address low
          inx                       ; set next msg byte
          bra disp0                 ; back to the beginning
.endproc

.proc     confirm
          pha
          ldx #(msg3-msg1)          ; ask confirm
          jsr disp
          jsr gtkey
          plx
          ora #$20                  ; to lower
          cmp #$f9                  ; "y"
          php
          txa
          plp
          rts
.endproc

; msg format
; A byte < $20 indicates high byte of address.
; Next byte must be low byte of address. Anything
; else are characters to display and will have their
; upper bit inverted before being written to the screen.
;
; The menu is constructed as follows:
; Standard IIc: msg1 + msg1a
; XDrive:       msg1 + msg1b
; ROMxc+:       above + msg4
msg1 = *
          .byte $05,$06,"0 Monitor"
          .byte $05,$86,"1 Reboot"
          .byte $06,$86,"3 System Diags.",$00 ; out of order to support JD Micro
msg1a:    .byte $06,$06,"2 Zero RAM Card and Reboot"
          .byte $07,$06,"4 RAM Card Diags."
msgc:     .byte $07,$86,"5 Boot SmartPort"
          .byte $04,$2e,"6 Boot Int. 5.25"
          .byte $04,$ae,"7 Boot Ext. 5.25"
          .byte $07,$5f,"By M.G."
msg2:     .byte $07,$db,"ROM 4X "
          .include "build_date.inc"
          .byte $05,$ae,$00                ; cursor pos in menu
msg3:     .byte $05,$b0,"SURE? ",$00
msg4:     .byte $05,$17,"8 ROMxc+",$00     ; after "0 Monitor"
msg1b:    .byte $07,$06,"4 Boot Xdrive",$FF,msgc-msg1 ; jumps to msgc
.assert *-msg1 <= 255, error, "boot menu too big"
          .dword .time              ; embed POSIX build time


; Boot4X - the boot portion of the program
.proc     boot4x
          jsr ntitle                ; "Apple //c"
          jsr xdrive_detect         ; check for xdrive, Z=1 if there
          bne :+                    ; no, do not try to recover ram disk
          lda power2 + rx_mslot     ; get action saved by reset4x
          beq boot4                 ; with xdrive, just boot slot 4 if no selection
          pha                       ; wastes a byte, I ugess
          bra selboot
:         jsr rdrecov               ; try to recover ramdisk
          lda power2 + rx_mslot     ; get action saved by reset4x
          beq :+                    ; unset, go look for config on ram card
          pha                       ; save it
          bra selboot               ; now go do it
:         lda numbanks,y            ; (y should be set in rdrecov) ram card present?
          beq boot6                 ; nope, boot slot 6 (it will fall through to slot 5)
          jsr getcfg                ; try to get config
          bcs boot4                 ; no config, normal boot
          ;stx $7d2 ; debug
          ;sty $7d3 ; debug
          phx                       ; config present, save selection and move on
          lda #'C'                  ; tell user
          sta $7d1                  ; on screen
selboot:  ldx #(msg2-msg1)          ; short offset
          jsr disp                  ; display it
          pla                       ; get boot selection from stack
btc2:     cmp #$02                  ; clear ramcard
          bne btc3
          jsr rdclear               ; do clear
          bra boot4
btc3:     cmp #$03                  ; Diags
          bne btc4
          jmp $c7c4
btc4:     cmp #$04                  ; RX diags or boot xdrive
          bne btc5
          jsr xdrive_detect         ; is there an Xdrive?
          beq boot4                 ; Xdrive present, boot slot 4
          ldx #$ff
          txs                       ; reset stack
          jsr rdinit                ; get x and y loaded
          stx sl_devno              ; diags need this
          jsr testsize              ; compute card size
          lda #>(monitor-1)         ; load "return" address
          pha                       ; into stack so that we
          lda #<(monitor-1)         ; exit card test into
          pha                       ; the monitor
          lda numbanks,y            ; get the card size in banks
          bne dordiag               ; do diag if memory present
          jmp swrts2                ; otherwise jump to monitor
dordiag:  jmp $db3a                 ; diags
          ;bra boot4
btc5:     cmp #$05                  ; boot smartport
          beq boot5
btc6:     cmp #$06                  ; boot int drive
          beq boot6
btc7:     cmp #$07                  ; boot ext drive
          bne boot4                 ; none of the above
          ; copy small routine to $800 to boot
          ; external 5.25
          ldy #.sizeof(bootext)
btc7lp:   lda bootext,y
          sta $800,y
          dey
          bpl btc7lp
          lda #$08                  ; copy done
          bra bootsl
boot4:    lda #rx_mslot             ; boot slot 4
          bra bootsl
boot5:    lda #$c5                  ; boot slot 5
          bra bootsl
boot6:    lda #$c6                  ; boot slot 6
bootsl:   ldx #$00                  ; low byte of slot
bootadr:  stx $0                    ; store address
          sta $1                    ; return to bank 0 does jmp (0)
endbt4x:  lda #>(bt4xrtn-1)
          pha
          lda #<(bt4xrtn-1)
          pha
          jmp swrts2
.endproc

.proc     rdrecov
          jsr rdinit                ; init ramcard
          lda pwrup,y               ; get power up flag
          cmp #pwrbyte              ; already initialized?
          beq recovdn               ; exit if initialized
          jsr testsize              ; does not wreck x or y
          lda numbanks,y            ; get discovered # banks
          beq recovdn               ; no mem
          stz addrl,x               ; set slinky address 0
          stz addrm,x
          stz addrh,x
          lda data,x                ; start check for bootable ramdisk
          cmp #$01
          bne recovdn               ; not bootable
          lda data,x                ; next byte should be nonzero and not $ff
          beq recovdn               ; not bootable
          cmp #$ff
          beq recovdn               ; not bootable
          lda #pwrbyte
          sta pwrup,y               ; set power byte
          lda #'R'                  ; tell user
          sta $7d0                  ; on screen
recovdn:  rts
.endproc

; zero ram card space
.proc     rdclear
          jsr rdinit                ; init ramcard
          jsr testsize              ; get size
          lda numbanks,y            ; # of 64Ks to write
          beq clrdone               ; no memory
          lda #$c0                  ; 'A' - 1
          sta $400                  ; upper left corner
          stz addrl,x               ; slinky address 0
          stz addrm,x
          stz addrh,x
clbnklp:  inc $400                  ; poor mans progress meter
          ldy #$00
cl64klp:  ldx #$00                  ; loop for all pages in bank
cl256lp:  txa                       ; loop for all bytes in page
          ldx #rx_devno
          stz data,x                ; write a zero to card
          tax
          dex
          bne cl256lp               ; 256 byte loop
          dey
          bne cl64klp               ; 64K loop
          ldx #rx_mslot
          dec numbanks,x
          bne clbnklp               ; if more banks
clrdone:  ldx #rx_mslot
          stz pwrup,x               ; zero powerup byte
          lda #$a0                  ; ' '
          sta $400                  ; clear progress
          rts
.endproc

.proc     rdinit
          bit rx_mslot*$100         ; activate registers
          ldy #rx_mslot             ; slot offset
          ldx #rx_devno             ; register offset
          rts
.endproc

; arrange a sequence of RTS tricks to display title screen
.proc   ntitle
        lda #>(swrts2-1)        ; put return addr of swrts/swrts2 on stack
        pha
        lda #<(swrts2-1)
        pha
        lda #>(banner-1)        ; put addr of the Title routine on the stack
        pha
        lda #<(banner-1)
        pha
        jmp swrts2              ; jump to swrts2
.endproc

; --------------------------------------------------
; config getter
; values and locs
        ;chktype = $5a              ; 'CFG'
        chktype   = $06             ; 'BIN' - easy to set auxtype with bsave
        entbuf    = $0280
; zp locs, safe to use under our circumstances
        blkptrl   = $06             ; block we are going to read
        blkptrh   = blkptrl + 1
        entryl    = $08             ; length of an entry
        nentries  = $09             ; number of entries per block
        blkcnt    = $0a             ; block counter for safety
.proc   getcfg
        jsr rdinit
        lda #$02                    ; first block of volume directory
        sta blkptrl
        stz blkptrh
        jsr setblk
        lda #$03                    ; want this to EOR out to $00
        ldy #$04                    ; check 4 bytes
:       eor data,x                  ; check previous blk ptr for zero
        dey
        bne :-
        cmp #$00                    ; see if A is 0
        bne nocfg                   ; not vol dir key block, end of mission
        lda #$04                    ; where we expect to find volume dir header
        sta addrl,x                 ; set data ptr
        lda data,x                  ; volume directory header first byte
        and #$f0                    ; mask off length
        cmp #$f0                    ; storage type is $f?
        bne nocfg                   ; nope, eom
        lda #$23                    ; offset of directory entry length in block
        sta blkcnt                  ; may as well use this for the safety check
        sta addrl,x                 ; set data pointer
        lda data,x                  ; grab entry length
        sta entryl                  ; save it
        ldy data,x                  ; entries per block
        sty nentries                ; save it for later
        bra nxtbl1                  ; skip setting slinky block and nentries, already there
nxtblk: jsr setblk
        beq nocfg                   ; just set block 0, eom
        dec blkcnt                  ; decrease safety counter
        beq nocfg                   ; and if we hit zero, bail out
        ldy nentries                ; restore # entries per block+1 into y
nxtbl1: jsr gnxtblk                 ; set next block pointer, leave data ptr at offset $04
nxtent: dey                         ; next entry, assumes y has # of entries remaining to check
        bmi nxtblk                  ; next block if we dont have any more (hope we don't have more than $7F of them)
        jsr rentry                  ; read directory entry
        ; now check storage type and name length
        lda entbuf
        and #$f0
        beq nxtent                  ; if storage type = $0
        and #$c0                    ; mask out values $1-$3 (normal files)
        bne nxtent                  ; if any other bits set
        lda entbuf+$10              ; get type
        cmp #chktype                ; and check
        bne nxtent                  ; no match, try next entry
        lda entbuf                  ; get storage type and length
        and #$0f                    ; mask in length
        cmp #(fname_-fname)         ; check length
        bne nxtent
        phy                         ; save num entries
        tay                         ; a still has length
mtchlp: lda entbuf,y                ; get file name char
        cmp fname-1,y               ; compare to what we are looking for
        bne nomtch                  ; if no match
        dey
        bne mtchlp                  ; check next char
        ; we have a match
        ply                         ; discard saved num entries
        ldx entbuf+$1f              ; low byte of aux type
        ldy entbuf+$20              ; high byte of aux type
        clc
        rts
nomtch: ply                         ; restore saved num entries
        bra nxtent
        ; no config found
nocfg:  sec
        rts
fname:  .byte "BOOTX"
fname_ = *
.endproc        
; get next block pointer into blkptrl and blkptrh
.proc   gnxtblk
        lda #$02                    ; assumes we are in first half of block
        sta addrl,x                 ; set byte offset
        lda data,x                  ; next block low byte
        sta blkptrl
        lda data,x                  ; next block high byte
        sta blkptrh
        rts
.endproc
; set slinky address to block pointer, address = blk num * 2 * $100
.proc   setblk
        stz addrl,x                 ; zero low byte of slinky address
        lda blkptrl                 ; low byte of block pointer
        ; sta $7e0
        asl                         ; shift left, high bit to c
        sta addrm,x                 ; put into middle byte of slinky address
        lda blkptrh                 ; get high byte of block pointer
        ; sta $7e1
        rol                         ; rotate left, c into bit 0
        sta addrh,x                 ; set high byte of slinky address
        ora addrm,x                 ; set z flag if we just set block 0
        rts
.endproc
; read a ProDOS directory entry from slinky
.proc   rentry
        phy                         ; preserve y
        ldy #$00
:       lda data,x
        sta entbuf,y
        iny
        cpy entryl
        bne :-
        ply
        rts
.endproc

; Display new boot failure message and jump to BASIC
.proc   nbtfail
        ldx #msglen
lp1:    lda bootmsg,x
        ora #$80
        sta $7d0+19-(<msglen/2),x
        dex
        bpl lp1
        lda #23		; last line
        sta cv
        lda #>(basic-1)
        pha
        lda #<(basic-1)
        pha
        jmp swrts2
bootmsg:
        .byte "No bootable device."
msglen = * - bootmsg - 1
.endproc

.ifdef EN_XMODEM
  .include "inc/xmodem.s"
.endif

; Enter with C=0 for detect XDrive and ROMXc+, C=1 for ROMXC+ menu
; if C=0, set jdm to %ab000000 where:
; a=1 if ROMxc+ present
; b=1 if xDrive present
.proc   jdmicro
        stz jdm         ; clear jdm
        php
        bcs :+          ; skip Xdrive detect if doing menu
        jsr xdrive_detect
        bne :+          ; if no xdrive
        ror jdm         ; put xdrive bit into jdm
        ; now copy ROMXc+ detection
:       ldy #jdm_romx_len
:       lda jd_romx_addr,y
        sta detcode,y
        dey
        bpl :-
        plp             ; get carry back
        jsr jd_romx     ; detect or activate ROMxc+ menu
        ror jdm         ; put romx bit into jdm
        rts
.endproc
.proc   xdrive_detect
        ldy #jd_xdrive_len
:       lda jd_xdrive_addr,y
        sta detcode,y
        dey
        bpl :-
        jmp jd_xdrive
.endproc

; detection routines for ROMxc+ and xDrive, to be called in RAM from aux ROM
jd_xdrive_addr = *
        tmporg detcode
; sets Z+C flag if XDrive present, -Z if not
.proc   jd_xdrive
        sta $C028       ; main ROM
        lda $C4F0       ; check signature bytes
        cmp #$CA
        bne :+
        lda $C4F1
        cmp #$CD
:       sta $C028       ; back to aux ROM
        rts
.endproc
        endtmporg jd_xdrive_len
.assert jd_xdrive_len < 128, error, "jd_xdrive_len too big"
jd_romx_addr = *
        tmporg detcode
; detect ROMXc+ if C=0, launch ROMXc+ menu if C=1
; for detect, return C=1 if ROMX present
.proc   jd_romx
        sta $C028       ; main ROM
        bcs romxmenu
        jsr activateromx
        beq :+          ; C=1 if Z=1
        clc
:       lda $F851       ; deactivate ROMX if it was activated
        sta $C028       ; back to aux ROM
        rts
romxmenu:
        jsr activateromx
        bne :+          ; if not activated!
        jmp $DFD0
:       sta $C028       ; back to aux ROM
        clc             ; shouldn't need this but just in case
        rts             ; it wasn't activated, return
.endproc
; activateromx returns Z=1 & C=1 if ROMx was activated
.proc   activateromx
        bit $FACA       ; ROMx activation sequence
        bit $FACA
        bit $FAFE
        lda $DFFE
        cmp #$4A
        bne :+
        lda $DFFF
        cmp #$CD
:       rts
.endproc
        endtmporg jdm_romx_len
.assert jdm_romx_len < 128, error, "jdm_romx_len too big"


