; center "Apple IIc +" on the screen
; for some reason Apple added " +" on the title, but
; then displayed it two characters to the *right* rather than one
; or to to the left.  It's a major
; pet peeve of mine, more so than the beep.
.code
	sta $040d,y

