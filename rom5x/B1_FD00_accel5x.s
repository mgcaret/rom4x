; Improved Apple IIc Plus accelerator firmware
; by M.G.

; Improvements over apple-supplied code:
; * bugs fixed
; * reset+<esc> toggles acclerator on/off rather than setting slow
; * warm reset preserves configured settings
; * additional commands to read/write accelerator speed
; * reset+<tab> configuration menu
; Config menu can be called independently from other alt
; bank firmware, such as ROM 5X

; note that in the current state, the code cannot be inserted
; into the ROM without moving the menu text and the speeds
; table.

.ifdef testaccel
TESTBLD = 1
.else
TESTBLD = 0                   ; set to 1 to enable test code that runs in random Apple II hw/emulator at $2000
                              ; this disables the bank switch and uses the main RAM at $0E00 to simulate the
                              ; MIG RAM.  Will configure a Zip Chip as if it were the IIc+ Accelerator.
.endif
XTRACMD = 0                   ; set to 1 to enable extra accelerator speed commands
ACCMENU = 1                   ; set to 1 to enable accelerator menu
ADEBUG  = 0                   ; turn on debugging (copies registers to $300 whenever they are set)
AOFFDFL = 0                   ; accelerator off by default

        .psc02
.if TESTBLD
  ; test build of accel code
  spdpct = 1
.else
  .include "iic+.defs"
.endif
; zero page
ZPAGE   = $00
COUNTER = ZPAGE+0             ; used as a generic counter for loops
CALLSP  = ZPAGE+1             ; stack pointer at call time
COMMAND = ZPAGE+2             ; command to execute
UBFPTRL = ZPAGE+3             ; user buffer pointer - low byte
UBFPTRH = ZPAGE+4             ; ditto - high byte
EXITCOD = ZPAGE+5             ; exit code from command

; stack
STACK   = $0100

; I/O
IOPAGE  = $C000
KBD     = IOPAGE+$00
KBDSTR  = IOPAGE+$10
ZIP5A   = IOPAGE+$5A
ZIP5B   = IOPAGE+$5B
ZIP5C   = IOPAGE+$5C
ZIP5D   = IOPAGE+$5D
ZIP5E   = IOPAGE+$5E
ZIP5F   = IOPAGE+$5F

; MIG
.if ::TESTBLD
MIGBASE = $0E00
.else
MIGBASE = $CE00
.endif
MIGRAM  = MIGBASE
PWRUPB0 = MIGRAM+0            ; powerup byte
PWRUPB1 = MIGRAM+1            ; powerup byte
ACWL    = MIGRAM+2            ; accelerator control word - low, also ZIP $C05C reg
ACWH    = MIGRAM+3            ; accelerator control word - high
KBDSAVE = MIGRAM+4            ; saved keystroke
ZIP5CSV = MIGRAM+5            ; configured $C05C register
ZIP5DSV = MIGRAM+6            ; configured $C05D register
ZIP5ESV = MIGRAM+7            ; configured $C05E register
ZIP5FSV = MIGRAM+8            ; configured $C05F register
ZPSAVE  = MIGRAM+$10          ; 8 zero page values saved here
MIGPAG0 = MIGBASE+$A0         ; MIG set page 0
MIGPAGI = MIGBASE+$20         ; MIG increment page

; fixed values
PWRUPV0 = $33
PWRUPV1 = $55
ESCKEY  = $9B
TABKEY  = $89

; routines we use
WAIT    = $FCA8
AUXWAIT = $FCB5
NORMAL  = $FC27
SWRTS2  = $C784

.if ::TESTBLD
        .org $2000
        lda   #$00
        pha
        jsr   ACCEL
        rts
.else
        .org $FD00
.endif
.proc   ACCEL
        bra   accel1
        jmp   AMENU
accel1: php
        sei
        phy
        phx
        bit   MIGPAG0
        bit   MIGPAGI
        bit   MIGPAGI
        ; save used ZP locations
        ldx   #$07
@loop:  lda   ZPAGE,x        
        sta   ZPSAVE,x
        stz   ZPAGE,x
        dex
        bpl   @loop
        ; get command & any parameters
        tsx
        txa
        tay
        iny
        lda   STACK+6,x
        sta   COMMAND
        cmp   #$05            ; read accelerator - first command with pointer parameter
        stx   CALLSP
        bcc   noparm          ; no parameter command
        lda   STACK+7,x
        sta   UBFPTRL
        lda   STACK+8,x
        sta   UBFPTRH
        iny
        iny
        inx
        inx
noparm: inx
        txs
        ldx   CALLSP
        lda   #$05
        sta   COUNTER
@loop:  lda   STACK+5,x
        sta   STACK+5,y
        dex
        dey
        dec   COUNTER
        bne   @loop
        lda   COMMAND
.if ::XTRACMD
        cmp   #$09            ; bad command number?
.else
        cmp   #$07
.endif
        bcc   docmd           ; no, do command
        lda   #$01
        sta   EXITCOD
        bra   acceldn
docmd:  asl   a               ; calculate jump table offset
        tax
        jsr   dispcmd         ; dispatch command
acceldn: 
        lda   EXITCOD
        pha
        ; restore zero page contnets
        ldx   #$07
@loop:  lda   ZPSAVE,x
        sta   ZPAGE,x
        dex
        bpl   @loop           ; fixed bug
        pla
        plx
        ply
        plp
        clc
        cmp   #$00
        beq   doexit
        sec
doexit: 
.if ::TESTBLD
        rts
.else
        jmp   SWRTS2
.endif
dispcmd:
        jmp   (cmdtable,x)
.endproc ; ACCEL 
; Initialize Accelerator (undocumented)
.proc   AINIT
        ; give time for user to hit key
        ldx   #$03
@loop:  lda   #$FF
.if ::TESTBLD
        jsr   WAIT
.else
        jsr   AUXWAIT
.endif
        dex
        bne   @loop
        ; now read keyboard
        lda   KBD
        sta   KBDSAVE
        ; check powerup bytes
        lda   PWRUPB0
        cmp   #PWRUPV0
        bne   coldst
        lda   PWRUPB1
        cmp   #PWRUPV1
        beq   warmst
coldst: lda   KBDSAVE
        ora   #$80
        sta   KBDSAVE
        jsr   MIGINIT
warmst: lda   KBDSAVE
        cmp   #ESCKEY
        bne   doinit
        ; toggle accelerator speed
        lda   ACWH            ; kept in ACWH
        eor   #$08            ; toggle bit 4
        sta   ACWH
doinit: jsr   AUNLK           ; unlock registers
        jsr   ASETR1          ; set registers
        jsr   ALOCK           ; lock accelerator
        ; set powerup bytes
        lda   #PWRUPV0
        sta   PWRUPB0
        lda   #PWRUPV1
        sta   PWRUPB1
.if ::ACCMENU
        ; now handle keyboard for menu
        lda   KBDSAVE
        cmp   #TABKEY
        bne   initdn
        sta   KBDSTR
        jsr   AMENU
.endif
initdn: lda   ACWH
        and   #$08
        beq   exinit          ; 0 if accel enabled
.if ::TESTBLD
        lda   #$4e
        sta   $0500
        sta   KBDSTR
.else
        jmp   NORMAL
.endif
exinit: rts
.endproc ; AINIT
; initialize values in MIG RAM
.proc   MIGINIT
        ldx   #$03
@loop:  lda   IREGV,x
        sta   ZIP5CSV,x
        dex
        bpl   @loop
        lda   IACWL
        sta   ACWL
        lda   IACWH
        sta   ACWH
        rts
.endproc ; MIGINIT
; conditionally enable accelerator according to bit 4 of Y register
.proc   ACOND
        tya
        and   #$08
        bne   ADISA
        ; otherwise fall through
.endproc ; ACOND
; enable accelerator
.proc   AENAB
        lda   #$08
        sta   ZIP5B
        trb   ACWH
        rts
.endproc ; AENAB
; disable accelerator
.proc   ADISA
        lda   #$08
        sta   ZIP5A
        tsb   ACWH
        rts
.endproc ; ADISA
; lock accelerator registers
.proc   ALOCK
        lda   #$A5
        sta   ZIP5A
        lda   #$10
        tsb   ACWH
        lda   #$80
        trb   ACWH          ; z flag is 0 if bit 7 was 0
        bne   :+            ; if DHiRes was off
        bit   ZIP5E         ; otherwise make sure it is on
        bra   :++
:       bit   ZIP5F         ; make sure it is off
:       rts
.endproc ; ALOCK
; unlock accelerator registers
.proc   AUNLK
        lda   $c07f         ; RdDHiRes - bit 7 = 1 if off, 0 if on
        and   #$80
        tsb   ACWH          ; put in ACWH
        lda   #$5A
        sta   ZIP5A
        sta   ZIP5A
        sta   ZIP5A
        sta   ZIP5A
        lda   #$10
        trb   ACWH
        rts
.endproc ; AUNLK
; read accelerator
.proc   AREAD
        ldy   #$00
        lda   ACWL
        sta   (UBFPTRL),y
        iny
        lda   ACWH
        sta   (UBFPTRL),y
        rts
.endproc ; AREAD
; write accelerator
.proc   AWRIT
        lda   #$40
        trb   ACWH            ; clear writable bits
        ldy   #$00
        lda   (UBFPTRL),y
        tax
        iny
        lda   (UBFPTRL),y
        and   #$40            ; all other bits reserved
        ora   ACWH            ; merge in existing ACWH less the bits we cleared above
        tay
        ;jsr   AUNLK          ; Apple code unlocks in write command, prob a bug.
        ;jsr   ASETR
        ;jsr   ALOCK          ; bug cont'd.
        ;rts
        ; fall through
.endproc ; AWRIT
; set accelerator registers
; x = new ACWL
; y = new ACWH
.proc   ASETR
;        php
;        pha
;        phx
        stx   ACWL
        stx   ZIP5CSV
        sty   ACWH
        lda   #$40            ; reset paddle speed
        trb   ZIP5FSV
        tya
        and   #$40            ; mask paddle speed
        ora   ZIP5FSV         ; merge with existing $c05f values
        sta   ZIP5FSV         ; and put back
        ; now set ZIP registers from MIG RAM
        ;jsr   ASETR1
;        plx
;        pla
;        plp
        ;rts
        ; fall through
.endproc ; ASETR1
; set accelerator registers from saved values in MIG
.proc   ASETR1
        ldx   #$03            ; set all registers from MIG
        stx   ZIP5B           ; turn on accelerator for writing
@loop:  lda   ZIP5CSV,x
        sta   ZIP5C,x
.if ::TESTBLD
        sta   MIGRAM+$0c,x    ; copy to unused locs for inspection
.endif
.if ::ADEBUG
        sta   $300,x          ; DEBUG
.endif
        dex
        bpl   @loop
        ldy   ACWH            ; ACWH
        jmp   ACOND           ; leave accelerator in configured state
.endproc ; ASETR1
cmdtable:
        .word AINIT
        .word AENAB
        .word ADISA
        .word ALOCK
        .word AUNLK
        .word AREAD
        .word AWRIT
.if ::XTRACMD
        .word ARSPD
        .word AWSPD
; get the accelerator speed register
.proc   ARSPD
        ldy   #$00
        lda   ZIP5DSV
        sta   (UBFPTRL),y
        rts
.endproc ; ARSPD
; write the accelerator speed register
.proc   AWSPD
        ldy   #$00
        lda   (UBFPTRL),y
        sta   ZIP5DSV
        tay
        jsr   AUNLK
        sty   ZIP5D
        jsr   ALOCK
        rts
.endproc ; AWSPD
.endif
IACWL:  .byte %01100111     ; initial ACWL - same as $C05C
.if ::AOFFDFL
IACWH:  .byte %01011000     ; initial ACWH - accelerator OFF. See below for bits
.else
IACWH:  .byte %01010000     ; initial ACWH - b6 = 1=paddle slow, b4 = reg 1=lock/0=unlock
                            ;                b3 = 1=accel disable, rest reserved by apple
                            ;                rom5x: b7 = state of DHiRes when accelerator was unlocked
.endif
IREGV:  .byte %01100111     ; Initial $C05C - slots & speaker: b7-b1 = slot speed. b0 = speaker delay
        .byte %00000000     ; Initial $C05D - $00 = 4MHz
        .byte %01000000     ; Initial $C05E - b7=0 enable I/O sync, b6=undoc
        .byte %01000000     ; Initial $C05F - b7=0 enable L/C accel, b6=1 paddle sync (slow)
.if ::ACCMENU
; accelerator config menu
; ---------|---------|---------|---------|
; Accel: On           Spk Dly: On
; Speed: 4.00         Pdl Dly: On
;
.proc   AMENU
        ; do this in case someone else calls us outside of AINIT
        bit   MIGPAG0
        bit   MIGPAGI
        bit   MIGPAGI
        ; save ZP locs we are using
        lda   COUNTER
        pha
        lda   UBFPTRH
        pha
        lda   UBFPTRL
        pha
amenu1: jsr   disp          ; disp menu with Accel Off
        lda   ACWH          ; get ACWH
        and   #$08          ; check accelerator enabled
        bne   aminp         ; if not, go to input
        ldx   #(msg2-msg1)  ; rest of menu
        jsr   disp0         ; on screen
        lda   ZIP5CSV       ; should be same as ACWL
        and   #$01          ; bit 1 = speaker delay, 1 = enable
        bne   dpdl          ; Skip if enabled
        lda   #$e6          ; Change on to off in menu
        sta   $06c6
        sta   $06c7
dpdl:   lda   ZIP5FSV       ; 5F register has paddle delay
        and   #$40          ; bit 6 = paddle delay (1 = slow)
        bne   dspd          ; 1 = on, skip
        lda   #$e6          ; change on to off in menu
        sta   $0746
        sta   $0747
dspd:   lda   ZIP5DSV       ; Speed in 5D register
        sta   COUNTER       ; if it is 4 MHz, this will stay 0
        tay
        beq   aminp         ; get input since menu already says 4.00
        ldx   #38           ; # of speeds(20) * 2 - 1
@sloop: lda   spdtab,x      ; get speed table speed byte
        tay
        and   #$fc          ; mask off irrelevant bits we use for MHz
        cmp   ZIP5DSV       ; see if matching
        beq   dspd1         ; if so, display it
        dex                 ; otherwise, next entry
        dex
        bpl   @sloop
        ; fall through will say 0.00 MHz or 00%
dspd1:  tya
        stx   COUNTER       ; which speed option is selected
.if ::TESTBLD
        stx   $0e1f         ; DEBUG
.endif
.if ::spdpct
        lda   #$a0          ; space
.else
        and   #$03          ; MHz value
        ora   #$b0          ; to digit
.endif
        sta   $072b         ; ones (MHz) or 100s (%)
        inx
        lda   spdtab,x
        tay
        lsr
        lsr
        lsr
        lsr
        ora   #$b0
.if ::spdpct
        sta   $072c         ; 10s (%)
.else
        sta   $072d         ; 10ths (MHz)
.endif
        tya
        and   #$0f
        ora   #$b0
.if ::spdpct
        sta   $072d         ; 1s (%)
.else
        sta   $072e         ; 100ths (MHz)
.endif
aminp:  ldy   #$00
        lda   #$60
        sta   (UBFPTRL),y
@kloop: lda   KBD
        bpl   @kloop
        bit   KBDSTR
ckrtn:  cmp   #$8d          ; return
        beq   exit
        and   #$df          ; upper case
ckA:    cmp   #$c1          ; 'A'
        bne   ckrest
        lda   ACWH
        eor   #$08
        sta   ACWH
        bra   tomenu
ckrest: tay
        lda   ACWH          ; get ACWH
        and   #$08          ; check accelerator enabled
        bne   tomenu        ; if not, do not allow changes
        tya
ckrt:   cmp   #$95          ; right arrow
        bne   cklt
        ldx   COUNTER
        dex
        dex
        bmi   tomenu
setspd: lda   spdtab,x
        and   #$fc
        sta   ZIP5DSV
        bra   tomenu
cklt:   cmp   #$88          ; left arrow
        bne   ckS
        ldx   COUNTER
        inx
        inx
        cpx   #35           ; should stop at 0.67
        bcc   setspd
        bra   tomenu   
ckS:    cmp   #$d3          ; 'S'
        bne   ckP
        lda   ZIP5CSV
        eor   #$01
        sta   ZIP5CSV
        sta   ACWL
        bra   tomenu
ckP:    cmp   #$d0          ; 'P'
        bne   tomenu
        lda   ZIP5FSV
        eor   #$40
        sta   ZIP5FSV
        lda   ACWH
        eor   #$40
        sta   ACWH
tomenu: jmp   amenu1
; restore saved values and set accelerator
exit:   pla
        sta   UBFPTRL
        pla
        sta   UBFPTRH
        pla
        sta   COUNTER
        jsr   AUNLK
        jsr   ASETR1
        jsr   ALOCK
        jmp   dclear
disp:   jsr   dclear
        inx
        ldy   #$00
disp0:  lda   msg1,x
        bne   disp1
        rts
disp1:  inx
        cmp   #$20          ; ' '
        bcc   disp2
        eor   #$80
        sta   (UBFPTRL),y
        inc   UBFPTRL
        bra   disp0
disp2:  sta   UBFPTRH
        lda   msg1,x
        sta   UBFPTRL
        inx
        bra   disp0
dclear: lda   #$a0
        ldx   #$27
@cloop: sta   $0628,x       ; line 12
        sta   $06a8,x       ; 13
        sta   $0728,x       ; 14
        sta   $07a8,x       ; 15
        dex
        bpl   @cloop
        rts
.if ::TESTBLD
.include "accelmenu.h"
spdtab:
.include "spdtab.h"
.else
msg1 = ::amenu1
msg2 = ::amenu2
.endif
.endproc ; AMENU
; check for run into vector area
.assert * < $ffe0, error, "accel5x overran $ffe0"
.endif
