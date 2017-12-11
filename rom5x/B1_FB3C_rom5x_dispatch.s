.code
.psc02
.include "iic+.defs"
          .org  $fb3c ; ~165 bytes free here
.proc     dispatch
          cmp   #$a9		      ; reset patch
          bne   :+
          jmp   reset5x
:         cmp   #$ea		      ; boot patch
          bne   :+
          jmp   boot5x
:         cmp   #$0c
          beq   oldbelle1
          ; jump to monitor
          lda   #>(monitor-1)	; monitor entry on stack as return address
          pha
          lda   #<(monitor-1)
          pha
          jmp   swrts2		    ; switch bank and rts to monitor
.endproc

; "classic air raid beep"
.proc     oldbell
          ldy   #$c0
obell2:	  lda   #$0c
dowait:   jsr   oldwait	  ; old wait for correct sound, we also enter here
          lda   $c030
          dey
          bne   obell2
          jmp   swrts2
.endproc
; We jump into the old bell routine mid-way because it's possible for
; someone to want to call the bell routine with a different duration
; by putting a custom value in Y and calling fbe4 (BELL2)
oldbelle1 := oldbell::dowait

; old wait - no ACIA access to enforce delay at
; accelerated speeds, speaker delay takes care of it
; when we do the old beep
.proc     oldwait
          sec
owait2:	  pha
owait3:   sbc   #$01
          bne   owait3
          pla
          sbc   #$01
          bne   owait2
          rts
.endproc

.assert * <= $fc00, error, "ROM 5X dispatch overruns $fc00"
