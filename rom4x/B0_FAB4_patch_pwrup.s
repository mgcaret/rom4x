; patch PWRUP to call boot4x

.include "iic.defs"
.code
	.org $fab4
	nop
	jmp gobt4x
