; patch RESET.X to call reset5x

.include "iic+.defs"
.code
	.org $fac8
	jmp gorst5x

