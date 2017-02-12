; patch RESET.X to call reset5x

#include "iic+.defs"
.text
* = $fac8
	jmp gorst5x

