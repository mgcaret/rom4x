# ROM 4X by MG

ROM 4X is a collection of enhancements to the Apple //c version 4.  See the top level [README.md](../README.md) for more general information on ROM 4X and ROM 5X.

It adds the following features to the Apple //c and IIc Plus firmware:

  - Identifies and reinstates a *bootable* (it must have something that looks like a boot block!) RAM disk from battery-backed expansion memory (see below), such as the [RAM Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144) from A2Heaven.
  - Provides a menu of various tools upon pressing Ctrl+Closed-Apple+Reset (or holding Closed-Apple when powering up), that let you:
    - Enter the monitor unconditionally.
    - Reboot the machine (enter standard boot sequence).
    - Zero the RAM card, in case it is corrupted.
    - Execute the machine and RAM card diagnostics.
    - Tell the machine to boot the SmartPort, the internal floppy drive, or an external floppy drive.
  - *New as of 04/25/2017*: By saving a file on the RAM card, control the way the system boots by default.
  - The system drops to BASIC if no bootable device is found (this is the default behavior in the IIc Plus).

# User Guide

## Installation

### Real System

Assuming you already have it burned onto a chip (I use SST27SF512s flash chips which hold 64K and Atmel 27C256, which hold 32K, and program with a TL866), generally the instructions [here](http://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Computers/Apple%20II/Apple%20IIc/Manuals/Apple%20IIc%20v4%20ROM%20Upgrade%20Installation.pdf) are relevant.  You won't need to cut any traces or solder a jumper unless, you are installing this ROM in an original //c.  I don't recommend installing it on a non-memory expansion //c unless you have expansion memory that looks like the 'slinky' memory of the later models.  ROM 4X/5X doesn't know about RAMWorks-style expansions.

Cards known to work with ROM 4X include the Apple Memory Expansion Card (but no battery!), and the A2Heaven [RAM Express II](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=146) for the original //c, and the [RAM Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144) for the memory-expandable //c and IIc Plus.

### Emulator

#### //c

Copy the ROM into the appropriate location for your emulator.  At the time of writing the only emulator I am aware of that can emulate the //c with memory expansion is [Catakig](http://catakig.sourceforge.net/) for MacOS.  It's a bit older of an emulator but it runs fine on newer MacOSes.

MAME's Apple //c emulation may work, but I have not tried it.

## Operation

### Menu

Power on your machine.  Everything should look and work *almost* like it did before.  If there is a bootable device somewhere, the machine will boot it.  If there is not (and this is one of the noticable changes), you will get dropped to BASIC without the need to press ctrl+reset.  If things don't go well, revisit your installation.

If you don't have an initialized RAM disk, format the card RAM disk with something like Copy II Plus.  Put ProDOS and BASIC.SYSTEM on it.  Power off the machine, and power it on after a few minutes.  You should boot off of the RAM disk.  You might notice an "R" flash on the screen for an instant before ProDOS loads.

Now, press Control+Closed-Apple+Reset, holding down Closed-Apple after releasing reset.  You should see the following menu appear (on a //c, IIc Plus menu is more compact to save firmware space):

```
0 Monitor
1 Reboot
2 Zero RAM Card and Reboot
3 Diagnostics
4 RAM Card Diagnostics
5 Boot SmartPort
6 Boot Int. 5.25
7 Boot Ext. 5.25
```

Picking any of the menu options besides 0 results in the menu being cleared, but the bottom line 'ROM 4X mm/dd/yy' immediately reappears to confirm that the new code is taking action.

What each option does is detailed below.  Note that the various device boot options will try that device and any remaining devices in the boot order, which for the Apple //c is RAM card, 5.25 drive, and finally SmartPort.

#### 0 Monitor

This drops you unconditionally into the monitor.

#### 1 Reboot

This carries out the normal boot sequence, which is to try the RAM disk first, then the internal 5.25 floppy drive, then the first connected smartport device.  Some of the other options let you skip over one or more of this ordering.

#### 2 Zero RAM Card and Reboot

This zeros out the RAM card memory and the screen holes.  This is a nuclear option if the RAM disk is corrupt and the system fails to boot.  After selecting 2 the word "SURE?" appears on the screen.  At this point you must type `Y` or `y` to continue with the zeroing, or any other key to cancel.

If there is no card RAM, you are immediately rebooted.  Otherwise an 'A' will appear in the upper left corner of the screen and will follow the alphabet as each 64K of the card is cleared.  After it completes the letter will disappear and the machine will try booting.

#### 3 Diagnostics

This jumps to the //c internal diagnostics that are also run when you press control+both-apples+reset.

#### 4 RAM Card Diagnostics

This runs the RAM card diagnostics.  When the diagnostics are finished either by user cancel or error, you are dropped into the monitor.

Since the test may damage data on the card, you are asked to confirm as per option 2 above.

#### 5 Boot SmartPort

This attempts to boot the first smartport device, such as a UniDisk 3.5.

#### 6 Boot Internal 5.25

This skips the RAM disk and starts booting with the internal 5.25 drive.

#### 7 Boot External 5.25

This is like option 6, but using an external 5.25 drive.  The only OS I am aware of that supports booting this way is ProDOS.

This destructively copies a short routine to $800, which under most circumstances is also immediately overwritten by the boot sector, so should not be a problem..

### Configuration File

**EXPERIMENTAL**

If the RAM card is ProDOS-formatted, you can save a binary file in the volume directory called `BOOTX`.  ROM 4X will find this file and use the Aux Type field (the load address) to set a default of the menu options above when no option has been selected using the menu.  For example, `BSAVE /RAM4/BOOTX,A6,L0` will cause ROM 4X to skip booting the RAM card and go straight to booting the internal floppy drive (menu item 6).  The contents of `BOOTX` are irrelevant, only the Aux Type is used.  You cannot set it to jump into the monitor because that action happens before the boot code takes over.

You will know the configuration file is being used because the ROM 4X line will appear on the bottom of the screen and a flashing 'C' will appear in the lower-left corner.

**WARNING**: You *can* set the `BOOTX` file to clear the RAM card or run the RAM card diagnostics.  This will happen exactly once and your RAM disk will be gone.  *Caveat emptor*.

# Build/Develop Guide

## Build

To build the new firmware, you must start with a copy of the repository, and obtain a copy of the Apple //c version 4 ROM.  The patches to the firmware work with the ROM dump that has sha256sum:


```
8ad5e6c4ed15d09b62183965b6c04762610d4b26510afc1896bdb4ecc55da883
```

It may work with other ROM dumps, it will *not* work with any other ROM versions, including ROM 3 and earlier.  You must build ROM 4X using a ROM 4 dump.

Place the ROM dump in the directory with the other files and name it `iic_rom4.bin`.

Now you will need a 65C02 cross assembler.  The current codebase is developed using ca65 from the [cc65](http://www.cc65.org/) project.  (Note: The code was developed originally using [xa](http://www.floodgap.com/retrotech/xa/)).

Finally you will need [Ruby](https://www.ruby-lang.org/en/) and [Rake](https://github.com/ruby/rake).

Once you have it all together change to the directory with the source files and original ROM image and type `rake`.

If all goes well, you will have a shiny new `iic_rom4x.bin` or `iic+_rom5x.bin`.

If you intend to build an image for a 512-kbit chip such as the SST27SF512, do `rake sf512`.

## Develop

### First Thing's First

First and foremost, it is most helpful to have an emulator.  The only one that I have found that can be used for (almost) thorough testing is [Catakig](http://catakig.sourceforge.net/) for MacOS.  It can emulate the //c and the Expansion Card (though not battery-backed).

If you plan to test on a real machine, be aware that the ROM socket is not rated for a large number of insertions and you *will* break something after a while.  You may consider putting a machine-pin DIP socket or a ZIF socket into the CPU socket position.  This can be done by desoldering the original socket if you have the skills, or by plugging the new socket into the existing CPU socket.  If you do do the latter you should consider the new socket permanent as the socket pins are thicker than a ROM chip's and removing it may leave the socket in such a state as to not be able to make good contact with a subsequent chip.

As for me, I just use the emulator and then I am very careful with changing the ROM when I want to test on the real hardware.  For heavy development/testing I insert a low-profile solder-tail ZIF socket into the existing chip socket..

### Apple //c Technical Reference and other Documentation

You need this.

The Apple //c Technical Reference Manual that is available on the internet has the firmware listing for ROM 3.  ROM 4 fixes a few bugs that were in ROM 3, including with the memory card driver.  The changes are minor and affect some of the offsets of routines in the RAM card support, but it is easy to figure them out.

[This](http://www.1000bit.it/support/manuali/apple/technotes/memx/tn.memx.1.html) tech note is also helpful as it documents the screen holes and some of the card behavior including under what conditions it reformats.  Though the power2 byte is *not* used by the Apple //c code -- it is commented out in the firmware listings in the Technical Reference.  ROM 4X uses it for the menu function.

[This](http://www.1000bit.it/support/manuali/apple/technotes/aiic/tn.aiic.5.html) technical note is a little less helpful for this project.

### Magic File Names

The main source files are named after a pattern, `B#_####_something.s` where the first # represents the bank number (0 = main, 1 = aux), and #### is the location in the bank to patch the code into.  E.G. the `B1_E000_rom4.bin`'s object code is loaded into bank 1 at E000.  Generally the origin address of the code in the file matches the #### portion of the file name.

The Rakefile uses this information to patch the original ROM 4 and produce the ROM 4X version.

### Defs

One file, `iic.defs` is included by all of the other source files.  This has entry points, origins, and various RAM locations defined in it for use by the other source code.

### Test Scenarios

#### Basic Functional Tests

  1. Boot ProDOS from power off.  Run SlotScan 1.62 and confirm that the slots are identified as expected, see below.
  2. With no bootable ProDOS RAMdisk, boot the system from power off or ctrl-oa-reset.
    1. With the drop-to-basic patch:
      - Expected: The system says "No bootable device" and drops to BASIC.
    2. Without to drop-to-basic patch:
      - Expected: The system boots the same as an unmodified ROM 4.
  3. With a bootable ProDOS RAMdisk containing ProDOS, boot the system from power off or ctrl-oa-reset.
    - Expected:  The system boots from RAM disk, an inverse or flashing R may appear on the left of line 24 of the display.
  4. Power on the system with the ca key pressed or use ctrl-ca-reset.
    - Expected:  The menu is displayed.
  5. RAM disk recovery:
    1. Battery-backed RAM present with bootable RAM disk:  Power off the machine and leave it for 1 hr.  Power on.
      - Expected:  The system boots from RAM disk.
    2. Non-battery-backed RAM present with bootable RAM disk:  Erase main RAM from 0300 up (e.g. in monitor: `300:00` then `301<300.BFFEM`) and press ctrl-reset.
      - Expected:  The system boots from RAM disk.

Expected SlotScan output:
```
SlotScan  Version 1.62                  Copyright 1989-1994 by Robert S. Claney 
--------------------------------------------------------------------------------
Apple Computer Type: //c, ROM Ver 4 (Newer Mem. Exp.)                           
Processor type: 65c02                                                           
Total RAM: 128K                                                                 
                                                                                
-----Scanning for peripherals-----                                              
Port 1: Serial Port (#1)                                                        
Port 2: Serial Port (#1)                                                        
Port 3: 80-Column Port (#8)                                                     
Port 4: RamCard SmartPort: 1 device found                                       
        Manufacturer #0 (Unknown)                                               
        Device 1: "RAMCARD",  Size: 2048 Blocks (1024K, 1 Meg)                  
             Type: Mem. expansion    Version: 0.102                             
             Addl. info:  (None)                                                
Port 5: SmartPort: 0 devices found                                              
Port 6: Disk ][ Port                                                            
        Device Size: 280 Blocks (140K)                                          
Port 7: Mouse Port (#0)                                                         
                                                                                
Done.  Press any key to continue, or Control-P to get a printout             
```


#### Menu Item Functional Tests

All cases:  When any menu option is selected, the "ROM 4X MM/DD/YY" message is displayed on the bottom of the screen.

  0. Monitor
    - Expected:  We are dropped into the monitor immediately.
  1. Reboot
    - Expected:  System boots as normal.
  2. Zero RAM Card and Reboot
    - Expected:  Reboot if no card RAM present.  Otherwise, counter appears in upper left corner and card RAM is cleared.
  3. Diagnostics
    - Expected:  System enters built-in diagnostics as if ctrl-oa-ca-reset was pressed.
  4. RAM Card Diagnostics
    - Expected:  System enters RAM card diagnostics if card RAM present, then/or (no mem) drops to monitor when exited by failure or user escape key.
  5. Boot SmartPort
    - Expected:  The system boots from a SmartPort device, skipping the RAM card and 5.25 floppy drives.
  6. Boot Internal 5.25
    - Expected:  The system boots from the internal 5.25 drive, skipping the RAM card.  The system may proceed to the SmartPort if no disk is found.
  7. Boot External 5.25
    - Expected:  The system boots from the external 5.25 drive, skipping the RAM card.  The system may proceed to the SmartPort if no disk is found.
    
### Ideas for Future

  - Replace Apple Slinky code with RamFactor code.  (Difficulty:  Hard)

