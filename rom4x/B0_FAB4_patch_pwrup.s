; patch PWRUP to call boot4x
.code
.include "iic.defs"
	.org $fab4
	nop
	jmp gobt4x
