# ROM 4X and 5X: The Whole Story

The Apple II Plus was the first computer my family owned.  It's what I learned to program on.  We spent hours at the keyboard typing in programs from magazines, and eventually I learned to modify them and write my own.  As technology progressed, I switched to PCs like almost everyone else and largely forgot about the Apple II after the 90s.  I still had an interest in my Apple IIs and managed to get hold of some more gear, including a //c and a couple of IIgs machines.  The prices bottomed out a few years after Apple discontinued the line.  Eventually I moved on and boxed it all up, sold a bit, but I held on to most of the interesting stuff I'd acquired.

## The Beginning and the New Old

I got back into the Apple II a few months ago after I read [this story](http://www.osnews.com/story/29400/Why_the_Apple_II_ProDOS_2_4_release_is_the_OS_news_of_the_year).  What?  A new ProDOS?  I must try it!   So I dusted off some of my old Apple II gear and the next thing you know I had ProDOS 2.4.1 running on my Apple //c.

So then I go searching around the net only to discover that not only is there a pretty active user community, but that people had been making *new hardware* for it, the coolest of which emulate floppy and hard drives.  There are Ethernet cards, memory expansions, VGA adapters, FPGA cards, and all kinds of other hardware.

Jumping into this new hardware for old computers craze, I bought a [Ram Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144#review) from [A2 Heaven](http://www.a2heaven.com/) and was excited to try out the whopping (really!) 1 MB of battery-backed memory in it, as well as the clock.  I formatted the card, loaded up ProDOS, and rebooted... Instant-on!  Much fast!

Then I powered down for a while to do non-hobby things.  Upon return, instead of a super fast boot to ProDOS, I got the the familiar clunking of the Apple 5 1/4 floppy drive recalibrating.  I thought to myself that surely I was doing something wrong, so I rebooted ProDOS and found the card in its initial state without what I had copied on it.

Bummer.

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

