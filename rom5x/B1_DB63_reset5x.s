.code
.psc02
.include "../macros/rompatch.macro"
.include "iic+.defs"
rompatch reset5x,157,"reset5x - ROM 5X reset routine"
          stz power2 + rx_mslot	; action = normal reset
          lda #>(rst5xrtn-1)	; common case
          pha
          lda #<(rst5xrtn-1)
          pha			; note that this stays on stack
          asl butn1		; option (closed apple)
          bcs ckdiag
exitrst:  jmp swrts2
; check to see if cmd_option (both apples) are down
ckdiag:   bit butn0		; command (open apple)
          bmi exitrst		; return to RESET.X
; present menu because only closed apple is down
menu:     jsr menu5x		; display menu
          jsr gkey5x
          cmp #$b0		; "0"
          bne ckkey1
          ldx #$ff		; reset stack
          txs
          txa
          jmp $fb3c   ; now has crash-to-monitor function
ckkey1:
          .ifndef jdm_xdrive
          ; this is all skipped if xdrive build
          cmp #$b2		; "2"
          beq doconf
          cmp #$b4		; "4"
          bne ckkey2
doconf:   jsr conf5x
          bne menu		; go back to menu4x
          .endif
ckkey2:   cmp #$b7		; "7"
          bne ckkey3
          jsr $fd02		; accelerator menu
          bra menu
ckkey3:   sec
          sbc #$b0		; ascii->number
          ; bmi menu		; (not needed?) < 0 not valid
          .ifdef jdm_romx
          cmp #$09      ; romx build has 8th option so >= 9 not valid
          .else
          cmp #$08      ; >= 8 not valid
          .endif
          bcs menu
          sta power2 + rx_mslot	; for boot5x
          stz softev + 1		; deinit coldstart
          stz pwerdup		; ditto
          bra exitrst
endpatch
