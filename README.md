# ROM 4X by MG

ROM 4X is an enhancement to the Apple //c version 4 firmware ROM.

It adds the following features to the Apple //c version 4 firmware:

  - Identifies and reinstates a ProDOS-formatted RAM disk from battery-backed expansion memory (see below).
  - Provides a menu of various tools upon pressing Ctrl+Closed-Apple+Esc (or holding Closed-Apple when powering up), that let you:
    - Enter the monitor unconditionally.
    - Reboot the machine (enter standard boot sequence).
    - Zero the RAM card, in case it is corrupted.
    - Execute the machine and RAM card diagnostics.
    - Tell the machine to boot the SmartPort, the internal floppy drive, or an external floppy drive.

The first feature listed above is the *raison d'etre* for the existence of this project.  The larger story is down below but in short:  The Apple //c memory card driver keeps certain information in the "screen holes" in main memory, which are required to use the memory card as a RAM disk.  Should these screen hole values disappear, the card is re-initialized to empty when ProDOS boots.  This happens even when the card is battery-backed and already has a RAM disk.  The card data is not damaged until ProDOS boots, but if you attempt to manually boot the RAM disk it will say "UNABLE TO START FROM MEMORY CARD" because the screen hole values are not initialized.

This firmware enhancement identifies a ProDOS boot block on the RAM disk and, if found, restores the appropriate screen holes to make the RAM disk bootable and prevent ProDOS from re-initializing it.

# User Guide

## Installation

### Real //c

Assuming you already have it burned onto a chip (I use Atmel 27C256, which hold 32K, and program with a TL866), follow the instructions [here](http://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Computers/Apple%20II/Apple%20IIc/Manuals/Apple%20IIc%20v4%20ROM%20Upgrade%20Installation.pdf).

### Emulator

Copy the ROM into the appropriate location for your emulator.  At the time of writing the only emulator I am aware of that can emulate the //c with memory expansion is [Catakig](http://catakig.sourceforge.net/) for MacOS.  It's a bit older of an emulator but it runs fine on newer MacOSes.

## Operation

Power on your //c.  Everything should look and work just like it did before. If not, revisit your installation.

Format the card RAM disk with something like Copy II Plus.  Put ProDOS and BASIC.SYSTEM on it.  Power off the machine, and power it on after, say, 15 minutes.  You should boot off of the RAM disk.  You might notice an "R" flash on the screen for an instant before ProDOS loads.

Now, press Control+Closed-Apple+Reset, holding down Closed-Apple after releasing reset.  You should see the following menu appear:

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

What each option does is detailed below.

### 0 Monitor

This drops you unconditionally into the monitor.

### 1 Reboot

This carries out the normal boot sequence, which is to try the RAM disk first, then the internal 5.25 floppy drive, then the first connected smartport device.  Some of the other options let you skip over one or more of this ordering.

### 2 Zero RAM Card and Reboot

This zeros out the RAM card memory and the screen holes.  This is a nuclear option if the RAM disk is corrupt and the system fails to boot.  After selecting 2 the word "SURE?" appears on the screen.  At this point you must type `Y` or `y` to continue with the zeroing, or any other key to cancel.

If there is no card RAM, you are immediately rebooted.  Otherwise an 'A' will appear in the upper left corner of the screen and will follow the alphabet as each 64K of the card is cleared.  After it completes the letter will disappear and the machine will try booting.

### 3 Diagnostics

This jumps to the //c internal diagnostics that are also run when you press control+both-apples+reset.

### 4 RAM Card Diagnostics

This runs the RAM card diagnostics.  When the diagnostics are finished either by user cancel or error, you are dropped into the monitor.

Since the test may damage data on the card, you are asked to confirm as per option 2 above.

### 5 Boot SmartPort

This attempts to boot the first smartport device, such as a UniDisk 3.5.

### 6 Boot Internal 5.25

This skips the RAM disk and starts booting with the internal 5.25 drive.

### 7 Boot External 5.25

This is like option 6, but using an external 5.25 drive.  The only OS I am aware of that supports booting this way is ProDOS.

This destructively copies a short routine to $300 so if you need to preserve what's there don't use this option.

# Build/Develop Guide

## Build

To build the new firmware, you must start with a copy of the repository containing this file, and obtain a copy of the Apple //c version 4 ROM.  The patches to the firmware work with the ROM dump that has sha256sum:

```
8ad5e6c4ed15d09b62183965b6c04762610d4b26510afc1896bdb4ecc55da883
```

It may work with other ROM 4 dumps, it will *not* work with any other ROM version, including ROM 3 and ROM 5 (from the IIc Plus).

Place the ROM dump in the directory with the other files and name it `iic_rom4.bin`.

Now you will need a 65C02 cross assembler.  The code was developed using [xa](http://www.floodgap.com/retrotech/xa/), mainly because it was available as a prebuilt binary in my preferred Linux distro's package repositories and supported the 65C02 opcodes.

Finally you will need [Ruby](https://www.ruby-lang.org/en/) and [Rake](https://github.com/ruby/rake).

Once you have it all together change to the directory with the source files and original ROM image and type `rake`.

If all goes well, you will have a shiny new `iic_rom4x.bin`.

## Develop

### First Thing's First

First and foremost, it is most helpful to have an emulator.  The only one that I have found that can be used for (almost) thorough testing is [Catakig](http://catakig.sourceforge.net/) for MacOS.  It can emulate the //c and the Expansion Card (though not battery-backed).

If you plan to test on a real //c, be aware that the ROM socket is not rated for a large number of insertions and you *will* break something after a while.  You may consider putting a machine-pin DIP socket or a ZIF socket into the CPU socket position.  This can be done by desoldering the original socket if you have the skills, or by plugging the new socket into the existing CPU socket.  If you do do the latter you should consider the new socket permanent as the socket pins are thicker than a ROM chip's and removing it may leave the socket in such a state as to not be able to make good contact with a subsequent chip.

As for me, I just use the emulator and then I am very careful with changing the ROM.

### Apple //c Technical Reference and other Documentation

You need this.

The Apple //c Technical Reference Manual that is available on the internet has the firmware listing for ROM 3.  ROM 4 fixes a few bugs that were in ROM 3, including with the memory card driver.  The changes are minor and affect some of the offsets of routines in the RAM card support, but it is easy to figure them out.

[This](http://www.1000bit.it/support/manuali/apple/technotes/memx/tn.memx.1.html) tech note is also helpful as it documents the screen holes and some of the card behavior including under what conditions it reformats.  Though the power2 byte is *not* used by the Apple //c code -- it is commented out in the firmware listings.

[This](http://www.1000bit.it/support/manuali/apple/technotes/aiic/tn.aiic.5.html) technical note is a little less helpful for this project.

### Magic File Names

The main source files are named after a pattern, `B#_####_something.s` where the first # represents the bank number (0 = main, 1 = aux), and #### is the location in the bank to patch the code into.  E.G. the `B1_E000_rom4.bin`'s object code is loaded into bank 1 at E000.  Generally the origin address of the code in the file matches the #### portion of the file name.

The Rakefile uses this information to patch the original ROM 4 and produce the ROM 4X version.

### Defs

One file, `iic.defs` is included by all of the other source files.  This has entry points, origins, and various RAM locations defined in it for use by the other source code.

# The Whole Story

The Apple II Plus was the first computer my family owned.  It's what I learned to program on.  We spent hours at the keyboard typing in programs from magazines, and eventually I learned to modify them and write my own.  As technology progressed, I switched to PCs like almost everyone else and largely forgot about the Apple II after the 90s.  But, I held on to most of the stuff I'd acquired for it, much of which became cheap in the years after Apple discontinued the product line.

## The Beginning and the New Old

I got back into the Apple II a few months ago after I read [this story](http://www.osnews.com/story/29400/Why_the_Apple_II_ProDOS_2_4_release_is_the_OS_news_of_the_year).  What?  A new ProDOS?  I must try it!   So I dusted off some of my old Apple II gear and the next thing you know I had ProDOS 2.4.1 running on my Apple //c.

So then I go searching around the net only to discover that not only is there a pretty active user community, but that people had been making *new hardware* for it, the coolest of which emulate floppy and hard drives.  There are Ethernet cards, memory expansions, VGA adapters, FPGA cards, and all kinds of other hardware.

Jumping into this new hardware for old computers craze, I bought a [Ram Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144#review) from [A2 Heaven](http://www.a2heaven.com/) and was excited to try out the whopping (really!) 1 MB of battery-backed memory in it, as well as the clock.  I formatted the card, loaded up ProDOS, and rebooted... Instant-on!  Much fast!

Then I powered down for a while to do non-hobby things, and instead of a super fast boot to ProDOS, I got the the familiar clunking of the Apple 5 1/4 floppy drive recalibrating.  I thought to myself that surely I was doing something wrong, so I rebooted ProDOS and found the card in its initial state without what I had copied on it.

Bummer

## Resetting My Expectations

Assuming the worst - that the battery wasn't working for the memory, I replaced the battery and checked that the clock had been working.  Still the same results.

I emailed the maker, Plamen, and asked about it.  He told me that something about the //c causes the card to reformat after power off.  To prove it, he had me write some values to the card manually and then read them back after powering off for an hour.

Turns out my expectations were wrong.  I followed up with a thanks and a "maybe I can find out in the firmware where that happens and fix it."  Another user got a card a few days later, and we discussed the matter over FaceBook, where I joked that it would be a "few NOPs" and when another user suggested adding boot from external drive back to the firmware I said that that would be much harder.  The exact opposite of what it was.

## Down the Rabbit Hole

I am a reasonably competent 8-bit assembly language programmer, always had been since I was a kid working on my Apple II Plus.  But I know the Z80 better these days, it'd been a long time since I touched the 6502.

Armed with a copy of Apple //c Technical Reference in PDF format, I printed out the firmware listings (computers used to have schematics and firmware listings available!) and started to look for where the few NOPs would have to go.

## pwerdup <> pwrbyte and numbanks == 0

After looking through the firmware listing, it was clear that the reason that the RAM disk was being reinitialized was because certain memory locations did not contain the contents needed to tell the firmware that it was already initialized.

These memory locations are in what are called "screen holes" in the Apple II.  Veteran Apple II users know what these are, but if you are unaware:  These are areas of the text screen that do not result in display output.  The Apple II text screen is not linearly organized and there are 8-byte "holes" after each 120 displayable locations.  Each of these holes is allocated to one of the card slots for slotted Apple IIs, or to the various ports of the unslotted Apple IIs.

In particular the firmware checks $77c (pwerdup) for the value $a5 (pwrbyte), and $47c for the number of banks detected on the card.  After some experimenting I determined that it is enough to set both of these to the proper values and the card will be recovered.  Setting these on an uninitialized card can result in all kinds of bad behavior, from crashes to perpetual "UNABLE TO LOAD PRODOS" depending on what is in the boot block.  Changing the firmware to ignore them  is not possible because we cannot assume the user is using the card as a RAM disk.

That means that instead of disabling code that purposely trashed the RAM disk, I had to add code to find an existing RAM disk and prevent re-initialization.

## From NOP codes to opcodes

Well, as we know, adding new code to existing firmware is a lot harder than disabling existing code.  We can't change where things already are, and any patches have to be at places that wouldn't break existing software.

But now I at least have some initial requirements:

>  1: Identify an existing, hopefully bootable RAM disk.
>  2: If it exists, prevent it from being re-initialized by setting the two screen holes to the proper values.
>  3: If no special action is taken, everything should "look normal."

The Apple II RAM card code is more simple than, say, the Applied Engineering RamFactor card, and I haven't seen anything that documents being able to boot DOS 3.3 or Pascal from it, so I decided that I only needed to see if the RAM disk was ProDOS and bootable.  So I would solve the first requirement by checking for a ProDOS boot block, conveniently starting at location zero on the card.

The second requirement we already sorted out above.  The third is that if you don't have a bootable RAM disk, booting the system should look and work just like it did before.  That's just good practice to not change things for the sake of change.

## Feature Creep

Then I thought to myself... what if the RAM disk is screwed up, and we keep re-initializing it and attempting to boot?  That's kind of a pain, but could be solved with documentation.  "Hit ctrl+reset and then pr#6 to boot a disk, then format the card with a program."

Nah.  Why not detect if the closed-apple key is pressed with ctrl+reset and clear out the RAM disk?

>  4: Provide a way to erase a messed up RAM disk.

Well, that wasn't so bad.  But what if the user doesn't want to erase it outright? Perhaps they want to try to recover some data.  Maybe we can leave it corrupted and just boot something else.

>  5: Provide a way to skip booting the RAM disk.

Well that's at least two options, and between the two apple key+reset combinations, no room for more than one additional action, so maybe that action should be a menu.

>  6: Present a menu to the user to decide what action to take.

Well since we are doing that, it's probably easy to get the IIc to try to boot whatever device you want, and maybe the user doesn't want to do any of the things on the menu.

>  7:  Let the user select a variety of boot devices.

Hell, while we are at it, let's give some easy access to internal functionality that requires more keys to be held down or calling routines in memory with BASIC or monitor commands.

>  8:  Let the user get access to the internal diagnostic routines.

Then, there was that guy that wanted to be able to boot an external 5.25 drive like the original //c firmware had.  This turned out to be fairly easy to do.

>  9:  Let the user boot an external 5.25 drive.

Well, I coded all the above up over the course of two days (short story, keep reading for longer version) and then I had another feature:

>  10:  Don't make it too easy to trash the RAM disk accidentally by picking menu option 2 and 4.

Sigh.  Now it's a real software project.

## Banking on It

After examining the //c ROM, it was clear that there was not any room in the main ROM bank to implement the above code, so the code had to run in the alternate bank.

When switching the ROM bank from ROM, you have to pull some tricks to make the switch safely and continue execution on the right code path.  The most compact way is to have a free place in both banks, which we have in the //c.  The less compact ways are to make use of subroutines already in the ROMs that can switch based on a memory location in RAM or by pushing the address to jump to on the stack and making use of the routine that switches banks and then does an RTS instruction (this is known as the 'RTS trick').  The latter are more useful for one-way jumps.

The second bank is also missing features that we take for granted, such as the various routines for displaying characters on the screen, clearing the screen, etc. so we need to find out which of these we should write ourselves and which ones to make available via a bank switch.

In the end the most difficult routine we might need from the firmware that we have to call and get back from is to clear the screen, since it has to be done without overwriting the screen holes.  Putting stuff on the screen is easy and there are compact ways of doing it.  The other functionality is pretty much one-way and for the common functions like jumping to an address for booting, the main needed functionality is in the firmware already.

In the end, I only needed the two-way switchers to enter and exit the reset handler (detects closed-apple and shows the menu), the boot handler (which handles the function selected by the user), and clearing the screen.  I decided to use the banner screen clear that prints 'Apple //c' at the top for me.  That meant that I needed 22 bytes of common unused address space in both banks for these, which I found.

The remaining switcher is one-way from alt bank to main bank, and I use the RTS trick.

## Patching Pants that Don't Have Holes

So now we have to patch the boot process to recover the RAM disk, and the reset process to capture the closed apple key and present the menu.

Well, firmware programmers for resource-limited machines don't exactly leave a bunch of space available for inserting your own routines, so I had to figure out where I could replace existing code with jumps and no-op padding.  Ideally you patch instructons in a 1:1 manner, a 3 byte instruction is replaced by another 3-byte instruction so that code that makes assumptions about where it can jump or call can continue to rely on those assumptions.

With the //c firmware I did not have that luxury for one of the patches, so hopefully it does not break things.  I think the chances are pretty low.

I searched over the course of an hour to figure out the best place to put the patches, and ROM 4X is the result.

## Conclusion

So now you have it and you know how it got here.  Enjoy ROM 4X.

