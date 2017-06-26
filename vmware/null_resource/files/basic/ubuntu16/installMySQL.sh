#!/bin/bash
#################################################################
# Script to install MySQL only
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

LOGFILE="/var/log/install_mysql.log"

USER=$1
PASSWORD=$2
HOST=$3

#update
apt-get update                                                                                           >> $LOGFILE 2>&1 || { echo "---Failed to update system---" | tee -a $LOGFILE; exit 1; }

#install mysql

echo "---start installing mysql---" | tee -a $LOGFILE 2>&1

echo "mysql-server-5.7 mysql-server/root_password password $PASSWORD" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $PASSWORD" | sudo debconf-set-selections
apt-get -y install mysql-server-5.7                                                                     >> $LOGFILE 2>&1 || { echo "---Failed to install mysql 5.7---" | tee -a $LOGFILE; exit 1; }

cat << EOF >> /etc/mysql/my.cnf 
[client]
user=root
password=$PASSWORD
EOF

mysql -e "CREATE USER '${USER}'@'${HOST}' IDENTIFIED BY '${PASSWORD}'; GRANT ALL PRIVILEGES ON * . * TO '${USER}'@'${HOST}'; FLUSH PRIVILEGES;"  >> $LOGFILE 2>&1 || { echo "---Failed to add user---" | tee -a $LOGFILE; exit 1; }

sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf                                 >> $LOGFILE 2>&1 || { echo "---Failed to update conf---" | tee -a $LOGFILE; exit 1; }
service mysql restart                                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to restart mysql---" | tee -a $LOGFILE; exit 1; }

ufw allow from $HOST to any port 3306                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to update firewall---" | tee -a $LOGFILE; exit 1; }

echo "---finish installing mysql---" | tee -a $LOGFILE 2>&1
