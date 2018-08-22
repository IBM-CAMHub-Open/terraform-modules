#!/bin/bash
#################################################################
# Script to install MongoDB, Strongloop, Angular on minions
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
set -o pipefail
set -o nounset


LOGFILE="/var/log/install_kubernetes_strongloop_three_tiers.log"

#number of strongloop and angular services 
Count=$1
#user password for mongoDB access
DBUserPwd=$2
#url to download scripts
SCRIPT_REPO=$3

STRONGLOOP_SCRIPT_URL=$SCRIPT_REPO/installStrongloop.sh
ANGULAR_SCRIPT_URL=$SCRIPT_REPO/installAngularJs.sh

MYIP=$(hostname --ip-address)

#################################################################
# create a todolist-mongodb deployment
#################################################################
echo "---create a replication controller for todolist-mongodb---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-mongodb-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: todolist-mongodb-deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: todolist-mongodb
    spec:
      containers:
      - name: todolist-mongodb
        image: mongo:3.4.0
EOF

kubectl create -f todolist-mongodb-deployment.yaml             >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-mongo deployment---" | tee -a $LOGFILE; exit 1; }

echo "---create an user in mongodb---" | tee -a $LOGFILE 2>&1
MongoPodStatus=$(kubectl get pod | grep "todolist-mongodb-deployment" | awk '{print $3}')
StatusCheckMaxCount=120
StatusCheckCount=0
while [ "$MongoPodStatus" != "Running" ]; do
	echo "---Check $StatusCheckCount: $MongoPodStatus---" | tee -a $LOGFILE 2>&1
	sleep 10
	let StatusCheckCount=StatusCheckCount+1	
	if [ $StatusCheckCount -eq $StatusCheckMaxCount ]; then
		echo "---Cannot connect to the mongodb container---" | tee -a $LOGFILE 2>&1 
		exit 1
	fi
	MongoPodStatus=$(kubectl get pod | grep "todolist-mongodb-deployment" | awk '{print $3}') 
done

MongoPod=$(kubectl get pod | grep "todolist-mongodb-deployment" | awk '{print $1}')
kubectl exec $MongoPod -- bash -c 'echo "db.createUser({user:\"sampleUser\", pwd: \"'$DBUserPwd'\", roles: [{role: \"userAdminAnyDatabase\", db: \"admin\"}]})" > mongouser.js' >> $LOGFILE 2>&1 || { echo "---Failed to create file in the container---" | tee -a $LOGFILE; }
sleep 30
kubectl exec $MongoPod -- mongo localhost:27017/admin mongouser.js                                                                                                              >> $LOGFILE 2>&1 || { echo "---Failed to add user---" | tee -a $LOGFILE; }

#################################################################
# define a service for the todolist-mongodb deployment
#################################################################
echo "---define a service for the todolist-mongodb---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-mongodb-service.yaml     
apiVersion: v1
kind: Service
metadata:
  name: todolist-mongodb-service
spec:
  externalIPs:
    - $MYIP
  ports:
    - port: 27017
  selector:
    app: todolist-mongodb
EOF

kubectl create -f todolist-mongodb-service.yaml               >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-mongo service---" | tee -a $LOGFILE; exit 1; }

#################################################################
# create a todolist-strongloop deployment
#################################################################

echo "---create a replication controller for todolist-strongloop---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-strongloop-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: todolist-strongloop-deployment
spec:
  replicas: $Count
  template:
    metadata:
      labels:
        app: todolist-strongloop
    spec:
      containers:
      - name: todolist-strongloop
        image: centos:latest
        command: ["/bin/bash"]
        args: ["-c", "curl -k -o installStrongloop.sh $STRONGLOOP_SCRIPT_URL;bash installStrongloop.sh $MYIP $DBUserPwd false;sleep infinity"]
        ports:
        - containerPort: 3000
EOF

kubectl create -f todolist-strongloop-deployment.yaml        >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-strongloop deployment---" | tee -a $LOGFILE; exit 1; }

#################################################################
# define a service for the todolist-strongloop deployment
#################################################################
echo "---define a service for the todolist-strongloop---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-strongloop-service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: todolist-strongloop-service
spec:
  externalIPs:
    - $MYIP
  ports:
    - port: 3000
  selector:
    app: todolist-strongloop
EOF

kubectl create -f todolist-strongloop-service.yaml          >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-strongloop service---" | tee -a $LOGFILE; exit 1; }

#################################################################
# create a todolist-angularjs deployment
#################################################################

echo "---create a replication controller for todolist-angularjs---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-angularjs-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: todolist-angularjs-deployment
spec:
  replicas: $Count
  template:
    metadata:
      labels:
        app: todolist-angularjs
    spec:
      containers:
      - name: todolist-angularjs
        image: centos:latest
        command: ["/bin/bash"]
        args: ["-c", "curl -k -o installAngularJs.sh  $ANGULAR_SCRIPT_URL;bash installAngularJs.sh $MYIP 8090 false;sleep infinity"]
        ports:
        - containerPort: 8090
EOF

kubectl create -f todolist-angularjs-deployment.yaml        >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-angularjs deployment---" | tee -a $LOGFILE; exit 1; }

#################################################################
# define a service for the todolist-angularjs deployment
#################################################################
echo "---define a service for the todolist-angularjs---" | tee -a $LOGFILE 2>&1
cat << EOF > todolist-angularjs-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: todolist-angularjs-service
spec:
  externalIPs:
    - $MYIP
  ports:
    - port: 8090
  selector:
    app: todolist-angularjs
EOF

kubectl create -f todolist-angularjs-service.yaml          >> $LOGFILE 2>&1 || { echo "---Failed to create todolist-anngular service---" | tee -a $LOGFILE; exit 1; }
