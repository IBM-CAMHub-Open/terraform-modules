#!/bin/bash
#################################################################
# Script to check if the http access is successful
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017.
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

echo "---check application status---"

APP_URL=$1

TMPFILE=`mktemp tmp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` && echo $TMPFILE
curl -k -s -o /dev/null -w "%{http_code}" -I -m 5 $APP_URL > $TMPFILE || true
SERVICE_STATUS=$(cat $TMPFILE)

while [ "$SERVICE_STATUS" != "200" ]; do
	echo "---application is being started---"
	sleep 10
	curl -k -s -o /dev/null -w "%{http_code}" -I -m 5 $APP_URL > $TMPFILE || true
	SERVICE_STATUS=$(cat $TMPFILE)
done
rm -f $TMPFILE	
	
echo "---application is up---"