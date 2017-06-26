#!/bin/bash
#####################################################################
# Script to install NodeJS, Angular, Express and sample application
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
#####################################################################

set -o errexit
set -o nounset
set -o pipefail

LOGFILE="/var/log/install_nodejs.log"

DBADDRESS=$1

echo "---Install nodejs---" | tee -a $LOGFILE 2>&1
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -                                                    >> $LOGFILE 2>&1 || { echo "---Failed to run node script to set up repo---" | tee -a $LOGFILE; exit 1; }
sudo apt-get install -y nodejs build-essential                                                                    >> $LOGFILE 2>&1 || { echo "---Failed to install nodejs and build essential---" | tee -a $LOGFILE; exit 1; }
sudo npm install -g bower gulp                                                                                    >> $LOGFILE 2>&1 || { echo "---Failed to install bower and gulp---" | tee -a $LOGFILE; exit 1; }

echo "---Install mean sample application---" | tee -a $LOGFILE 2>&1
git clone https://github.com/meanjs/mean.git mean                                                                 >> $LOGFILE 2>&1 || { echo "---Failed to clone mean sample project---" | tee -a $LOGFILE; exit 1; }
cd mean
npm install                                                                                                       >> $LOGFILE 2>&1 || { echo "---Failed to install node modules---" | tee -a $LOGFILE; exit 1; }
bower --allow-root --config.interactive=false install                                                             >> $LOGFILE 2>&1 || { echo "---Failed to install bower---" | tee -a $LOGFILE; exit 1; }

PRODCONF=config/env/production.js
sed -i -e "/    uri: process.env.MONGOHQ_URL/a\ \ \ \ uri: \'mongodb:\/\/"$DBADDRESS":27017/mean\'," $PRODCONF    >> $LOGFILE 2>&1 || { echo "---Failed to update db config---" | tee -a $LOGFILE; exit 1; }
sed -i -e 's/    uri: process.env.MONGOHQ_URL/\/\/    uri: process.env.MONGOHQ_URL/g' $PRODCONF                   >> $LOGFILE 2>&1 || { echo "---Failed to update db config---" | tee -a $LOGFILE; exit 1; }
sed -i -e 's/ssl: true/ssl: false/g' $PRODCONF                                                                    >> $LOGFILE 2>&1 || { echo "---Failed to update db config---" | tee -a $LOGFILE; exit 1; }

#npm run start:prod &                                                                                              >> $LOGFILE 2>&1 || { echo "---Failed to update db config---" | tee -a $LOGFILE; exit 1; }

#make sample application as a service
SAMPLE_APP_SERVICE_CONF=/etc/systemd/system/nodeserver.service
cat << EOF > $SAMPLE_APP_SERVICE_CONF
[Unit]
Description=Node.js Example Server

[Service]
ExecStart=/usr/bin/gulp prod --gulpfile $HOME/mean/gulpfile.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nodejs-example
Environment=NODE_ENV=production PORT=8443

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nodeserver.service                                                                                >> $LOGFILE 2>&1 || { echo "---Failed to enable the sample node service---" | tee -a $LOGFILE; exit 1; }
systemctl start nodeserver.service                                                                                 >> $LOGFILE 2>&1 || { echo "---Failed to start the sample node service---" | tee -a $LOGFILE; exit 1; }

echo "---finish installing sample application---" | tee -a $LOGFILE 2>&1 
