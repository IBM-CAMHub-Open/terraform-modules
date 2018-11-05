#!/bin/bash

ILMT_FILE_PATH=/etc/opt/BESClient
ILMT_FILE=$ILMT_FILE_PATH/cam_swtag.id

if ! [ -f $ILMT_FILE ]; then
	echo "$ILMT_FILE does not exist on this system, creating it now."
	sudo mkdir -p $ILMT_FILE_PATH
	
	sudo cp /tmp/cam_swtag.id $ILMT_FILE
else
	echo "$ILMT_FILE already exists on this system, do nothing."
fi
