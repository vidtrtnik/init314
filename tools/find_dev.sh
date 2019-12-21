#!/bin/bash

DEVICE="$1"

if [[ -z "$DEVICE" ]]; then exit 0; fi
	
ls -1 /dev/sd* | 
while read dev; do 
	ret=$(udevadm info -n "$dev" | grep "ID_SERIAL=" | grep "$DEVICE")
	if [[ ! -z "$ret" ]]; then printf "$dev\n"; exit 1; fi 
done
