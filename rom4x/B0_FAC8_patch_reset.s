; patch RESET.X to call reset4x
.code
.include "iic.defs"
	.org $fac8
	jmp gorst4x

