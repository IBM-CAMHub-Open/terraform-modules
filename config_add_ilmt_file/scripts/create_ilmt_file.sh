#!/bin/bash

ILMT_FILE_PATH=/etc/opt/CAM/swidtag
ILMT_FILE_NAME=ibm.com_IBM_Cloud_Automation_Manager_managed_system-3.1.0.swidtag
ILMT_FILE=$ILMT_FILE_PATH/$ILMT_FILE_NAME

if ! [ -f $ILMT_FILE ]; then
  echo "$ILMT_FILE does not exist on this system, creating it now."
  sudo mkdir -p $ILMT_FILE_PATH
  
  sudo cp /tmp/$ILMT_FILE_NAME $ILMT_FILE
else
  echo "$ILMT_FILE already exists on this system, do nothing."
fi
