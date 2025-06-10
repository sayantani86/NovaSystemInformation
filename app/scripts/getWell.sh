#!/bin/bash

WELLNAME=$3

WELLNAME=$(echo $WELLNAME | sed s'/\s\+//g' | sed s'/#//g' | sed s'/-//g' )

source "$SCRIPTS_DIR/searchWell.sh" $1 $2 $WELLNAME 

status=$?

if [ $status -eq 0 ]; then
	if ! [ -f "$SCRIPTS_DIR/PatchIQ/WELL_FILES_WEEKLY/$WELLNAME.sh" ]; then
		source "$SCRIPTS_DIR/ironiq_create_script_for_well_saving_weekly.sh" $WELLNAME
	fi
fi

source "$SCRIPTS_DIR/PatchIQ/WELL_FILES_WEEKLY/$WELLNAME.sh" $1 $2 $4 $5
