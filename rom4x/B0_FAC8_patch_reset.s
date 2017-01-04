; patch RESET.X to call reset4x

#include "iic.defs"
.text
* = $fac8
	jmp gorst4x

