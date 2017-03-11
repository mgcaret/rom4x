; this reverses the accelerator to always start off at 1MHz
; <ESC> at reset then selects 4 MHz
; This is useful if you spend more time at 1 MHz, for games

.text
* = $fdd5
	.byte $f0

