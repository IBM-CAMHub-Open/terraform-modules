#!/bin/bash
#################################################################
# Script to install Nginx on minions
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

LOGFILE="/var/log/install_kubernetes_nginx.log"

# number of nginx
Count=$1

MYIP=$(hostname --ip-address)

#################################################################
# create an nginx deployment
#################################################################
echo "---create a replication controller for nginx---" | tee -a $LOGFILE 2>&1
cat << EOF > nginx-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: $Count
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF

kubectl create -f nginx-deployment.yaml                       >> $LOGFILE 2>&1 || { echo "---Failed to create nginx deployment---" | tee -a $LOGFILE; exit 1; }

#################################################################
# define a service for the nginx deployment
#################################################################
echo "---define a service for the nginx rc---" | tee -a $LOGFILE 2>&1
cat << EOF > nginx-service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  externalIPs:
    - $MYIP 
  ports:
    - port: 80
  selector:
    app: nginx
EOF

kubectl create -f nginx-service.yaml                         >> $LOGFILE 2>&1 || { echo "---Failed to create nginx service---" | tee -a $LOGFILE; exit 1; }
