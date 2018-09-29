#!/bin/bash
# Script to zip the built images
rm -f "romXx_dist-*.zip"
ROM4X="rom4x/iic_rom4x.bin"
ROM5X="rom5x/iic+_rom5x.bin"
case `uname -s` in
Linux)
	FNAME="romXx_dist-`date --rfc-3339=date`.zip"
	;;
*)
	FNAME="romXx_dist-`date '+%Y-%M-%d'`.zip"
	;;
esac
[ -f "${ROM4X}" ] && zip "${FNAME}" "${ROM4X}"
[ -f "${ROM5X}" ] && zip "${FNAME}" "${ROM5X}"

