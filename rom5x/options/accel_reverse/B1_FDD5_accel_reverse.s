; this reverses the accelerator to always start off at 1MHz
; <ESC> at reset then selects 4 MHz
; This is useful if you spend more time at 1 MHz, for games

; This patch was inspired by Quinn Dunki's functionally equivalent
; firmware mod found here: http://quinndunki.com/blondihacks/?p=2546

.text
* = $fdd5
	.byte $f0

