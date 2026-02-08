; patch RDKEY to skip over NOPs and add in additional code for handling
; delete key.
.code
.PC02
.include "iic+.defs"
  .org $fd10
  bra :+            ; skip over the patch
	lda #$88          ; replace with left arrow code
  bra $fd7c         ; branch back out of the patch
: