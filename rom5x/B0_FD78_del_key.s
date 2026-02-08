; patch GETLN1 to call delete key handler
;
; This patch uses the run of NOPs in RDKEY since there wasn't enough space here
; (6 bytes needed, 5 available).
.code
.include "iic+.defs"
	.org $fd78
  cmp #$ff          ; check for delete
  beq $fd12         ; go to part 2 of the patch
  cmp #$95          ; check for control-u
  bne $fd84
  jsr $cc1d         ; lift char

