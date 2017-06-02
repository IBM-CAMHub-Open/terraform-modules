#!/bin/bash
#################################################################
# Script to deploy apache and php in day 2
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

LOGFILE="/var/log/deployApplication.log"
PUBLIC_MYSQL_DNS=$1
MYSQL_USER=$2
MYSQL_PWD=$3
PHP_FILE=$4
PUBLIC_DNS=$5

echo "---setup $PHP_FILE---" | tee -a $LOGFILE 2>&1

sed -i "s/localhost/$PUBLIC_MYSQL_DNS/" /tmp/application/$PHP_FILE
sed -i "s/dbuser/$MYSQL_USER/" /tmp/application/$PHP_FILE
sed -i "s/dbpassword/$MYSQL_PWD/" /tmp/application/$PHP_FILE

cp /tmp/application/$PHP_FILE /var/www/html/$PUBLIC_DNS/public_html/$PHP_FILE

systemctl restart apache2

echo "---installed application successfully---" | tee -a $LOGFILE 2>&1

