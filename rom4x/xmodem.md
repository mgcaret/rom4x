# ROM 4X XModem-CRC

The 10/01/2018 release of ROM 4X includes XModem-CRC functionality.

The feature restores functionality to the SAVE and LOAD commands in AppleSoft BASIC, and re-introduces the W and R commands in the monitor.

The commands send/receive data through the Modem Port of the Apple //c.

The XModem-CRC functionality has been tested between the Apple //c and a PC running [Qodem](http://qodem.sourceforge.net) and between two Apple //cs using a null modem cable. 

## Use of the XModem-CRC features

By default the data is sent at 115,200 bps 8N1.  If you want to keep the current serial port speed/bits setting, hold the Closed Apple key while pressing the RETURN key for the below commands.  Note that if the serial port is configured for 7 bit data, the transfer will fail.

**Caveats**:  An XModem block is 128 bytes, and that is the minimum size that will be transmitted (extra filled with Ctrl+Z) and received (extra is copied to memory!).  In the case of the receiver, multiples of 128 bytes (124 for first block) of memory will be overwritten as each block is received.  4 bytes are added to the transmitted data for a header (see below).  So sending between 1 and 124 bytes of data will overwrite 124 bytes in the target machine's memory, but sending 125 bytes will overwrite 252 bytes!  Keep this in mind!

### AppleSoft BASIC

To send the current program through the modem port, type `SAVE`.  A 'W' will appear in the upper right corner of the screen, and after several seconds will start flashing.  The save routine will wait approximately one minute for a receiver to be ready, otherwise it will exit and say "ERR".  If you accidentally type SAVE, hit the ESC key and you will be returned to AppleSoft (again, with 'ERR').  Once the transfer starts, the upper right corner will cycle from 0 through 7 as each block is received (this is the lower 3 bits of the block number).

To receive a program through the modem port, type `LOAD`.  A 'R' will appear in the upper right corner, and start flashing after a few seconds.  The load routine will attempt to initiate the transfer every 3 seconds for one minute, otherwise exit with 'ERR'.  If you wish to cancel the transfer, hit the ESC key.  If you hit ESC before any blocks are received, your current program will stay intact.  Once blocks are received, if the transfer fails or is cancelled, it will be as if NEW had been executed.  A successful transfer results in the downloaded program being in memory.

### Monitor

To send data, type `xxxx.yyyyW`, as if you were using a machine with a cassette port, to send the data between addresses `xxxx` and `yyyy` (inclusive).  The routine has the same wait/error conditions as the AppleSoft `SAVE` command, above.

To receive data, you can type `0R` to receive at the same address from which the data was written, or `zzzzR` to receive at address `zzzz` instead.  The routine has the same receive/error conditions as the AppleSoft `LOAD` command, above.

As an example, you can copy the hi-res graphics page 1 from one machine to another via null modem cable by typing `2000.3FFFW` on the machine with the graphics and `0R` on the other machine.

## Troubleshooting

Occasionally the serial port gets finicky and receiving will instantly result in an ERR. Doing a trivial `SAVE` or `W` on the receiver, and then canceling and restarting the receive, will usually resolve this. 

## Data Format

The data is sent/received via the XModem-CRC protocol, **without fallback to plain XModem**.  Most modern terminal programs support XModem-CRC.

The data is sent with a 4-byte header in the first block that contains the address and length (minus one) of the data being sent.  The exact length is sent in order to avoid leaking memory when receiving an AppleSoft program, as XModem does not have a built-in means of providing the length of the transfer.

When receiving, the machine will continue to receive blocks regardless of the length it receives in the first block, until the sender indicates it is done sending.

When transferring between an Apple //c and a PC, the 4-byte header must be included when sending a file to the //c.   This will be present in any file originally received from a //c via XModem-CRC, but you will need to find a way to add it to anything that did not.

## Credits

I got the idea to implement this while discussing on Facebook the fact that `SAVE` and `LOAD` on the //c jump to the ampersand vector.  The Facebook "Apple II Enthusiasts" group has inspired a lot of what I put into ROM 4X/5X.

I'd like to thank Reactive Micro for stepping up to deliver the ROM to people who can't build/burn it on their own.  I have no desire to be in the taking orders/shipping business, and I am grateful, as are others, that there is someone who is.

Finally, the XModem-CRC routines are modified versions of Daryl Rictor's routines available at [6502.org](http://www.6502.org/source/io/xmodem/xmodem.htm).


