; patch PWRUP to call boot5x

.include "iic+.defs"
.code
	.org $fab4
	nop
	jmp gobt5x
