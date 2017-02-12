; patch PWRUP to call boot5x

#include "iic+.defs"
.text
* = $fab4
	nop
	jmp gobt5x
