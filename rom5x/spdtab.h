; speed table for 4 MHz IIc Plus
; this was confirmed by measuring a delay loop
; for each speed.  The delay loop was timed
; timed to 1/100 sec accuracy using the Ram
; Express II+ dclock.
        .byte %00000000,$00 ; 4.0000
        .byte %00100011,$33 ; 3.3333
        .byte %00010011,$20 ; 3.2000
        .byte %00001011,$00 ; 3.0000
        .byte %00000110,$67 ; 2.6667
        .byte %01000010,$00 ; 2.0000
        .byte %01100001,$67 ; 1.6667
        .byte %01010001,$60 ; 1.6000
        .byte %01001001,$50 ; 1.5000
        .byte %11000001,$33 ; 1.3333
        .byte %11100001,$11 ; 1.1111
        .byte %11010001,$07 ; 1.0667
        .byte %11001001,$00 ; 1.0000
        .byte %11000100,$89 ; 0.8889
        .byte %10100000,$83 ; 0.8333
        .byte %10010000,$80 ; 0.8000
        .byte %10001000,$75 ; 0.7500
        .byte %10000100,$67 ; 0.6667

