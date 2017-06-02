#!/bin/bash
#################################################################
# Script to install apache and php
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

LOGFILE="/var/log/installApache2.log"
PUBLIC_DNS=$1
PUBLIC_MYSQL_DNS=$2
MYSQL_USER=$3
MYSQL_PWD=$4

echo "---my dns hostname is $PUBLIC_DNS---" | tee -a $LOGFILE 2>&1
hostnamectl set-hostname $PUBLIC_DNS                                                        >> $LOGFILE 2>&1 || { echo "---Failed to set hostname---" | tee -a $LOGFILE; exit 1; }

#update

echo "---update system---" | tee -a $LOGFILE 2>&1 
apt-get update                                                                              >> $LOGFILE 2>&1 || { echo "---Failed to update system---" | tee -a $LOGFILE; exit 1; }

echo "---install apache2---" | tee -a $LOGFILE 2>&1 
apt-get install -y apache2                                                                  >> $LOGFILE 2>&1 || { echo "---Failed to install apache2---" | tee -a $LOGFILE; exit 1; }

echo "---set keepalive Off---" | tee -a $LOGFILE 2>&1 
sed -i 's/KeepAlive On/KeepAlive Off/' /etc/apache2/apache2.conf                            >> $LOGFILE 2>&1 || { echo "---Failed to config apache2---" | tee -a $LOGFILE; exit 1; }

echo "---enable mpm_prefork---" | tee -a $LOGFILE 2>&1 
cp /tmp/apache2/mpm_prefork.conf /etc/apache2/mods-available/
a2dismod mpm_event                                                                          >> $LOGFILE 2>&1 || { echo "---Failed to set mpm event---" | tee -a $LOGFILE; exit 1; }
a2enmod mpm_prefork                                                                         >> $LOGFILE 2>&1 || { echo "---Failed to set mpm perfork---" | tee -a $LOGFILE; exit 1; }

echo "---restart apache2---" | tee -a $LOGFILE 2>&1
systemctl restart apache2                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to restart apache2---" | tee -a $LOGFILE; exit 1; }

echo "---setup virtual host---" | tee -a $LOGFILE 2>&1
cp /tmp/apache2/$PUBLIC_DNS.conf /etc/apache2/sites-available/
mkdir -p /var/www/html/$PUBLIC_DNS/{public_html,logs}
a2ensite $PUBLIC_DNS                                                                        >> $LOGFILE 2>&1 || { echo "---Failed to setup virtual host---" | tee -a $LOGFILE; exit 1; }

echo "---setup helloworld.html---" | tee -a $LOGFILE 2>&1
cp /tmp/apache2/helloworld.html /var/www/html/$PUBLIC_DNS/public_html/helloworld.html       >> $LOGFILE 2>&1 || { echo "---Failed to setup html---" | tee -a $LOGFILE; exit 1; }

echo "---disable default virtual host and restart apache2---" | tee -a $LOGFILE 2>&1
a2dissite 000-default.conf                                                                  >> $LOGFILE 2>&1 || { echo "---Failed to disable default virtual host---" | tee -a $LOGFILE; exit 1; }
systemctl restart apache2                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to restart apache2---" | tee -a $LOGFILE; exit 1; }

echo "---install php packages---" | tee -a $LOGFILE 2>&1 
apt-get install -y php7.0 php-pear libapache2-mod-php7.0 php7.0-mysql                       >> $LOGFILE 2>&1 || { echo "---Failed to install php packages---" | tee -a $LOGFILE; exit 1; }

mkdir /var/log/php
chown www-data /var/log/php

echo "---setup test.php---" | tee -a $LOGFILE 2>&1
# need to modify test.php with mysql server hostname, uid, pwd then copy it

sed -i "s/localhost/$PUBLIC_MYSQL_DNS/" /tmp/apache2/test.php                               >> $LOGFILE 2>&1 || { echo "---Failed to config test.php---" | tee -a $LOGFILE; exit 1; }
sed -i "s/dbuser/$MYSQL_USER/" /tmp/apache2/test.php                                        >> $LOGFILE 2>&1 || { echo "---Failed to config test.php---" | tee -a $LOGFILE; exit 1; }
sed -i "s/dbpassword/$MYSQL_PWD/" /tmp/apache2/test.php                                     >> $LOGFILE 2>&1 || { echo "---Failed to config test.php---" | tee -a $LOGFILE; exit 1; }

cp /tmp/apache2/test.php /var/www/html/$PUBLIC_DNS/public_html/test.php

systemctl restart apache2                                                                   >> $LOGFILE 2>&1 || { echo "---Failed to restart apache2---" | tee -a $LOGFILE; exit 1; }

echo "---installed apache2 and php successfully---" | tee -a $LOGFILE 2>&1

