# ROM 5X by MG

## PRELIMINARY, NOT EXTENSIVELY TESTED

This is ROM 5X, providing the ROM 4X functionality to the Apple IIc Plus ROM
version 5.

There are almost no free bytes in the main bank of the IIc Plus firmware, so
I had to get creative to get into the alternate bank, where I then had to split
the code up across multiple smaller free spaces due to the massive 3.5 drive
handling code.  Ironically this makes the code larger as well.

For those interested, I hijack the monitor BEEP1 routine.  The beep routine has
an LDA #$40 and then calls WAIT with this value for a .1 second delay,
presumably so that multiple beeps are distinct from each other.

I patch the JSR WAIT to be STA $C028, which switches to the other bank.
The code in the other bank checks the accumulator and for two values calls
either reset5x or boot5x, and for any other value executes the WAIT (assuming
that we got there from BEEP1) and returns back to BEEP1.

Then, in only 6 bytes I can create two entry points that load the value into
A that we need for the reset or boot routines, and then jump to the above patch.


