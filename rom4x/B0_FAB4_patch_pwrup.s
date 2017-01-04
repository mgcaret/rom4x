; patch PWRUP to call boot4x

#include "iic.defs"
.text
* = $fab4
	nop
	jmp gobt4x
