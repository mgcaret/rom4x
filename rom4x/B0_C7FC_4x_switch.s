; There's a bit of luck in the firmware
; there are 4 $00 bytes at $C7FC in the main bank, of which the last
; is "AppleTalk version" according to the ROM $03 source code
; in the tech ref, and should be left at $00.
; There are also 7 $00 bytes at $C7FC in the aux bank.  So if we switch at
; $C7FC, then we get a 4 bytes in the aux bank, just enough for a jump.
.code
	.org $c7fc
	sta $c028

