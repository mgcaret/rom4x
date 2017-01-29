# ROM 5X by MG

## DO NOT EVEN TRY THIS YET :-)

**Warning:** This has not been tested on an emulator or a real Apple IIc Plus.

This is a patch for the Apple IIc Plus firmware that tries to recover a battery-backed
RAM disk upon cold start.  Because of the limited space in the Apple IIc ROM. it does not
have the complete feature set of ROM 4X for the (non-Plus) //c.

Upon cold start, the patch checks for a potentially bootable RAM disk and restores the
appropriate screen holes to prevent it from being destroyed and to enable boot.  If a
RAMdisk is recovered, a flashing "R" will appear in the lower left corner of the screen.

To prevent the check and recovery, power on the machine with the Option key held down.
A flashing "O" will appear in the lower left corner of the screen and the system will
boot without checking for or recovering any RAM disk.

