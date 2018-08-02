# ROM 5X by MG

ROM 5X is a collection of enhancements to the Apple //c Plus (ROM version 5).  See the top level [README.md](../README.md) for more general information on ROM 4X and ROM 5X.

It adds the following features to the Apple //c Plus:

    - Enter the monitor unconditionally.
    - Reboot the machine (enter standard boot sequence).
    - Zero the RAM card, in case it is corrupted.
    - Execute the machine and RAM card diagnostics.
    - Tell the machine to boot the SmartPort/3.5 drive or the internal floppy drive.
    - Menu control the built-in accelerator (via main menu or ctrl+tab+reset).
    - Accelerator settings persist across resets.
    - Build option to default the system to 1 MHz.
    - Changes ctrl+esc+reset to toggle the accelerator rather than turn it off only.

RAM expansion cards known to work with ROM 5X include the AE RAM Express Cards (but no battery!), and the A2Heaven [RAM Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144) for the memory-expandable //c and IIc Plus.

# User Guide

## Obtaining

**Due to copyright law, I do NOT provide full ready-to-burn binaries at this time.  Some assembly (but not necessarily an assembler) is required!**

You may either build it yourself which guarantees that you have the latest version and feature branch that you want, or you can check the [web site for ROM 4X/5X](http://apple2.guidero.us/doku.php?id=projects:rom_4x_and_5x) for binary releases.

### Binary Releases

The binary releases consist of a zip file with the assembled and linked patches, a checksum file, and a Bash script.  You must have a unix-like system (MacOS, Linux, etc.) or, on Windows, Cygwin or the Windows Subsystem for Linux configured.

The shell script will perform the following:

  * Download the original Apple ROM image from a well-known location.
  * Apply the patches.
  * Validate the checksums of both the original ROM image and the patched ROM image.

## Installation

### Real System

Burn the ROM image (generally named iic_rom4x.bin) onto a 27C256 chip, or burn twice (into the lower and upper halves) of a 27C512 chip.  If you can obtain an SST27SF512 flash EEPROM, that is a great option.

Once you have a ROM chip, generally the instructions [here](http://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Computers/Apple%20II/Apple%20IIc/Manuals/Apple%20IIc%20v4%20ROM%20Upgrade%20Installation.pdf) are relevant.  You won't need to cut any traces or solder a jumper unless you are installing this ROM in an original //c.


### Emulator

Copy the ROM into the appropriate location for your emulator.  As of July 2018, the following emulators are known to successfully emulate the Apple IIc Plus:

  * [Leon Bottou](https://github.com/leonbottou)'s "universal" versions of GSPlus and KEGS.
  * MAME after [this commit](https://github.com/mamedev/mame/commit/31aaae7491ea4233de75456af178054e650f4344).

## Operation

### Menu

Power on your machine.  Everything should look and work *almost* like it did before.  If there is a bootable device somewhere, the machine will boot it.  If things don't go well, revisit your installation.

If you don't have an initialized RAM disk, format the card RAM disk with something like Copy II Plus.  Put ProDOS and BASIC.SYSTEM on it.  Power off the machine, and power it on after a few minutes.  You should boot off of the RAM disk.  You might notice an "R" flash on the screen for an instant before ProDOS loads.

Now, press Control+Option+Reset, holding down Option after releasing reset.  You should see the following menu appear:

```
0 Monitor
1 Reboot
2 Zero RAM Card
3 Sys Diags
4 RAM Card Diags
5 Boot 3.5/SmartPort
6 Boot 5.25
7 Accelerator
```

Picking any of the menu options besides 0 results in the menu being cleared, but the bottom line 'ROM 5X mm/dd/yy' immediately reappears to confirm that the new code is taking action.

What each option does is detailed below.  Note that the various device boot options will try that device and any remaining devices in the boot order, which for the Apple IIc Plus is RAM card, 3.5 or SmartPort, and finally the first 5.25 drive, if present.

#### 0 Monitor

This drops you unconditionally into the monitor.

#### 1 Reboot

This carries out the normal boot sequence, which is to try the RAM disk first, then the internal 5.25 floppy drive, then the first connected smartport device.  Some of the other options let you skip over one or more of this ordering.

#### 2 Zero RAM Card

This zeros out the RAM card memory and the screen holes.  This is a nuclear option if the RAM disk is corrupt and the system fails to boot.  After selecting 2 the word "SURE?" appears on the screen.  At this point you must type `Y` or `y` to continue with the zeroing, or any other key to cancel.

If there is no card RAM, you are immediately rebooted.  Otherwise an 'A' will appear in the upper left corner of the screen and will follow the alphabet as each 64K of the card is cleared.  After it completes the letter will disappear and the machine will try booting.

#### 3 Sys Diags

This jumps to the //c Plus internal diagnostics that are also run when you press control+apple+option+reset.

#### 4 RAM Card Diags

This runs the RAM card diagnostics.  When the diagnostics are finished either by user cancel or error, you are dropped into the monitor.

Since the test may damage data on the card, you are asked to confirm as per option 2 above.

#### 5 Boot 3.5/SmartPort

This attempts to boot the first bootable smartport device, such as a the built-in 3.5" drive.

#### 6 Boot 5.25

This skips the RAM disk and starts an attached 5.25 drive.

#### 7 Accelerator

This opens the accelerator menu.

### Accelerator Menu

The Accelerator menu can be accessed by selecting "Accelerator" from the boot menu, or by pressing the tab key during or within 1 second of pressing ctrl+reset.

The accelerator menu will allow you to enable or disable the accelerator, set the speed, and control speaker and paddle delay.

The settings will persist through resets.

# Build/Develop Guide

## Build

To build the new firmware, you must start with a copy of the repository, and obtain a copy of the Apple IIc Plus version 5 ROM.  The patches to the firmware work with the ROM dump that has sha256sum:

```
5a62070f6a0b07784681d4df4bf2ce88b2809bec0cbaa65fcb963e804ed60374
```

It may work with other ROM dumps, it will *not* work with any other ROM versions, including ROM 4 and earlier from the original //c.  You must build ROM 4X using a ROM 5 dump.

The Rakefile will download the file from a well-known location if it is not already present.  It also verifies the checksum.

Now you will need a 65C02 cross assembler.  The current codebase is developed using ca65 from the [cc65](http://www.cc65.org/) project.  Only the assembler and linker are required.  Older versions may complain about argument order, generally versions identifying as "2.16" built from the ca65 git master branch work fine.

Finally you will need [Ruby](https://www.ruby-lang.org/en/) and [Rake](https://github.com/ruby/rake).

Once you have it all together change to the directory with the source files and original ROM image and type `rake`.

If all goes well, you will have a shiny new `iic_rom5x.bin`.

If you intend to build an image for a 512-kbit chip such as the SST27SF512, do `rake sf512`.

### Build Options

There are some build options in accel5x.s - some functional, others needing more
work, the most popular of which will no doubt be the option to reset the system
with the accelerator in the disabled state.  The "extra commands" option will
currently fail to build because the code gets too large, and is really only for
experimental purposes.

## Develop

### First Thing's First

See above for the list of working emulators that can run the Apple IIc Plus firmware.

If you will test on a real machine, be aware that the ROM socket is not rated for a large number of insertions and you *will* break something after a while.  You may consider putting a machine-pin DIP socket or a ZIF socket into the CPU socket position.  This can be done by desoldering the original socket if you have the skills, or by plugging the new socket into the existing CPU socket.  If you do do the latter you should consider the new socket permanent as the socket pins are thicker than a ROM chip's and removing it may leave the socket in such a state as to not be able to make good contact with a subsequent chip.

### Nitty Gritty

There are almost no free bytes in the main bank of the IIc Plus firmware, so I had to get creative to get into the alternate bank, where I then had to split the code up across multiple smaller free spaces due to the massive 3.5 drive handling code.  Ironically this makes the code larger as well.

### Apple //c Technical Reference and other Documentation

You need this.

The Apple //c Technical Reference Manual that is available on the internet has the firmware listing for ROM 3.  ROM 4 fixes a few bugs that were in ROM 3, including with the memory card driver.  The changes are minor and affect some of the offsets of routines in the RAM card support, but it is easy to figure them out.  ROM 5 adds the 3.5 drive code, but largely leaves the main firmwware bank untouched.

[This](http://www.1000bit.it/support/manuali/apple/technotes/memx/tn.memx.1.html) tech note is also helpful as it documents the screen holes and some of the card behavior including under what conditions it reformats.  Though the power2 byte is *not* used by the Apple //c code -- it is commented out in the firmware listings in the Technical Reference.  ROM 5X uses it for the menu function.

[This](http://www.1000bit.it/support/manuali/apple/technotes/aiic/tn.aiic.5.html) technical note is a little less helpful for this project.

### Magic File Names

The main source files are named after a pattern, `B#_####_something.s` where the first # represents the bank number (0 = main, 1 = aux), and #### is the location in the bank to patch the code into.  E.G. the `B1_E000_rom4.bin`'s object code is loaded into bank 1 at E000.  Generally the origin address of the code in the file matches the #### portion of the file name.

The Rakefile uses this information to patch the original ROM 5 and produce the ROM 5X version.

### Defs

One file, `iic+.defs` is included by all of the other source files.  This has entry points, origins, and various RAM locations defined in it for use by the other source code.

### Test Scenarios

#### Basic Functional Tests

  1. Boot ProDOS from power off.  Run SlotScan 1.62 and confirm that the slots are identified as expected, see below.
  2. With no bootable ProDOS RAMdisk, boot the system from power off or ctrl-oa-reset.
    - Expected: The system says "No bootable device" and drops to BASIC.
  3. With a bootable ProDOS RAMdisk containing ProDOS, boot the system from power off or ctrl-oa-reset.
    - Expected:  The system boots from RAM disk, an inverse or flashing R may appear on the left of line 24 of the display.
  4. Power on the system with the ca key pressed or use ctrl-ca-reset.
    - Expected:  The menu is displayed.
  5. RAM disk recovery:
    1. Battery-backed RAM present with bootable RAM disk:  Power off the machine and leave it for 1 hr.  Power on.
      - Expected:  The system boots from RAM disk.
    2. Non-battery-backed RAM present with bootable RAM disk:  Erase main RAM from 0300 up (e.g. in monitor: `300:00` then `301<300.BFFEM`) and press ctrl-reset.
      - Expected:  The system boots from RAM disk.


#### Menu Item Functional Tests

All cases:  When any menu option is selected, the "ROM 5X MM/DD/YY" message is displayed on the bottom of the screen.

Check each item, the expectation is that the sytem does what is listed in the menu.

### Ideas for Future

  - Replace Apple Slinky code with RamFactor code.  (Difficulty:  Hard.  May require sacrificing the diagnostics.)


