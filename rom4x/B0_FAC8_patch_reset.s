; patch RESET.X to call reset4x

.include "iic.defs"
.code
	.org $fac8
	jmp gorst4x

