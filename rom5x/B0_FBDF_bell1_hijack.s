; Hijack the BELL1 monitor routine to do our bidding.
; BELL1 implements the beep sound heard on reset or
; Ctrl-G, etc.  It starts with
; LDA #$40
; JSR WAIT ; delay .1 sec
; followed by code to actually beep the speaker
; In our case, BELL1 always loads the accumulator with
; a fixed number, and executes a 3-byte instruction
; Well, it turns out that to switch banks we need
; 3 bytes, and as luck would have it the other bank
; is empty here.
; So the routine on the other side is the ROM 5X
; dispatcher. It will take what is in the accumulator
; and use that to determine the next action.
; Obviously, $40 should beep the speaker, anything
; else can do whatever we want.

.text
* = $fbdf
	sta $c028

