# ROM 4X and 5X by MG

ROM 4X and 5X are enhancements to the Apple //c version 4 and Apple IIc Plus firmware ROMs.

It adds the following features to the Apple //c and IIc Plus firmware:

  - Identifies and reinstates a *bootable* (it must have something that looks like a boot block!) RAM disk from battery-backed expansion memory (see below), such as the [RAM Express II+](http://a2heaven.com/webshop/index.php?rt=product/product&product_id=144) from A2Heaven.
  - Provides a menu of various tools upon pressing Ctrl+Closed-Apple+Reset (or holding Closed-Apple when powering up), that let you:
    - Enter the monitor unconditionally.
    - Reboot the machine (enter standard boot sequence).
    - Zero the RAM card, in case it is corrupted.
    - Execute the machine and RAM card diagnostics.
    - Tell the machine to boot the SmartPort, the internal floppy drive, or an external floppy drive.
  - IIc only:
    - The system drops to BASIC if no bootable device is found (this is the default behavior in the IIc Plus).
    - Configure default boot device by saving a file on the RAM Disk.
  - IIc Plus only:
    - Menu control the built-in accelerator.
    - Accelerator settings persist across resets.
    - Build option to default the system to 1 MHz.
  

The first feature listed above is the *raison d'etre* for this project.  The larger story is down below but in short:  The Apple //c memory card driver keeps certain information in the "screen holes" in main memory, which are required to use the memory card as a RAM disk.  Should these screen hole values disappear, the card is re-initialized to empty when ProDOS boots.  This happens even when the card is battery-backed and already has a RAM disk.  The card data is not damaged until ProDOS boots, but if you attempt to manually boot the RAM disk it will say "UNABLE TO START FROM MEMORY CARD" because the screen hole values are not initialized.

This firmware enhancement identifies a ProDOS boot block on the RAM disk and, if found, restores the appropriate screen holes to make the RAM disk bootable and prevent firmware or ProDOS from re-initializing it.

## Build / Install / Documentation

### ROM 4X

See the [ROM 4X README.md](rom4x/README.md).

### ROM 5X

See the [ROM 5X README.md](rom5x/README.md).


## The Whole Story

See [story.md](story.md).

