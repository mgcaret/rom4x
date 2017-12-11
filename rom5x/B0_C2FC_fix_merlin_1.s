; Code to fix merlin incompatibility with the beep patch
; this arises because switching to the aux firmware messes up the
; memory map slightly.  The IIc Plus WAIT routine has a fix, we adopt it here.
.code
.pc02
            .org $c2fc
            phx
            jmp   $c9a1     ; next step
