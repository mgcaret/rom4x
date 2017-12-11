; Fix the beep
; inspired by http://quinndunki.com/blondihacks/?p=2471
; see commentary in B1 FB3C patch
.code
.pc02
          .org $fbe6
          jmp  $c2fc        ; to 5X beep with merlin fix
          .res $fbef-*,$ea  ; fill up the rest with NOPs
.assert * = $fbef, error, "ROM 5X beep fix alignment problem"
; the rts at $fbef is sacred

          
          