#include "iic+.defs"
.text
* = $fce1
	sta set80col	; instruction we patched over
	jmp rom5x

