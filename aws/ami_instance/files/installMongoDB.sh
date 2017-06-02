#!/bin/bash
#################################################################
# Script to install MongoDB
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

LOGFILE="/var/log/install_mongodb.log"

echo "---Install mongodb---" | tee -a $LOGFILE 2>&1

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6                                                      >> $LOGFILE 2>&1 || { echo "---Failed to obtain key for mongo---" | tee -a $LOGFILE; exit 1; }
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list    >> $LOGFILE 2>&1 || { echo "---Failed to add repo---" | tee -a $LOGFILE; exit 1; }
sudo apt-get update                                                                                                                                             >> $LOGFILE 2>&1 || { echo "---Failed to update system---" | tee -a $LOGFILE; exit 1; }
sudo apt-get install -y mongodb-org                                                                                                                             >> $LOGFILE 2>&1 || { echo "---Failed to install mongodb-org---" | tee -a $LOGFILE; exit 1; }

sudo sed -i -e 's/  bindIp/#  bindIp/g' /etc/mongod.conf                                                                                                        >> $LOGFILE 2>&1 || { echo "---Failed to update mongod.conf---" | tee -a $LOGFILE; exit 1; }
sudo service mongod start                                                                                                                                       >> $LOGFILE 2>&1 || { echo "---Failed to start mongod service---" | tee -a $LOGFILE; exit 1; }

echo "---Done---" | tee -a $LOGFILE 2>&1
