; see B0 C2FC patch for commentary
.code
.pc02
          .org  $c9a1
          jsr   $cfe5   ; get memory config we need to fix
          jsr   $c7fc   ; call ROM 5X dispatch
          jmp   $c2f5   ; fix memory, restore x, a=$00
