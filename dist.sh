#!/bin/bash -x
# Script to zip/tarball the built images
ext=.tar.bz2
cmd="tar cvjf"
if [ "$1" == "zip" ]; then
  ext=.zip
  cmd=zip
fi
files=$(ls rom4x/iic_rom4x*.bin rom5x/iic+_rom5x*.bin)
case `uname -s` in
Linux)
	FNAME="rom4x5x_dist-`date --rfc-3339=date`${ext}"
	;;
*)
	FNAME="rom4x5x_dist-`date '+%Y-%M-%d'`${ext}"
	;;
esac
rm -f $FNAME
$cmd $FNAME $files
