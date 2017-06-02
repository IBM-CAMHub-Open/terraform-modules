#!/bin/bash
#################################################################
# Script to create User
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# Copyright IBM Corp. 2017.
#
#################################################################

set -o errexit
set -o nounset
set -o pipefail

LOGFILE="/var/log/createCAMUser.log"

apt-get update                                                                            >> $LOGFILE 2>&1 || { echo "---Failed to update---" | tee -a $LOGFILE; exit 1; }
apt-get install python-minimal -y                                                         >> $LOGFILE 2>&1 || { echo "---Failed to python-minimal---" | tee -a $LOGFILE; exit 1; }

echo "---start createCAMUser---" | tee -a $LOGFILE 2>&1

CAMUSER=${variable_1}
CAMPWD=${variable_2}

PASS=$(perl -e 'print crypt($ARGV[0], "password")' $CAMPWD)
useradd -m -s /bin/bash -p $PASS $CAMUSER                                                 >> $LOGFILE 2>&1 || { echo "---Failed to create user---" | tee -a $LOGFILE; exit 1; }
echo "$CAMUSER ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config     >> $LOGFILE 2>&1 || { echo "---Failed to config sshd---" | tee -a $LOGFILE; exit 1; }
echo "AllowUsers ubuntu $CAMUSER" >> /etc/ssh/sshd_config
service ssh restart                                                                       >> $LOGFILE 2>&1 || { echo "---Failed to restart ssh---" | tee -a $LOGFILE; exit 1; }

echo "---finished creating CAMUser $CAMUSER---" | tee -a $LOGFILE 2>&1 