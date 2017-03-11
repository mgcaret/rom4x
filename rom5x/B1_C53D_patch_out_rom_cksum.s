; Patch the Apple IIc+ diagnostics to skip the ROM checksum test.
; We should really examine the routine at $D249 in the aux firmware
; to see if we can calculate a new checksum.
; the $D249 routine copies a small routine into the zero page that
; calculates the checksum.  It returns with carry set = error and
; carry clear = OK.  So we just patch the JSR to always clear the
; carry.  For now.
* = $C53D
.text
	nop
	nop
	clc

