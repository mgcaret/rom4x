; patch GETLN1 to call delete key handler
.code
.include "iic+.defs"
	.org $fd75
	jsr $c4ee

