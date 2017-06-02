#!/bin/bash
#################################################################
# Script to install Kubernetes Minion Node
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

LOGFILE="/var/log/install_kubernetes_minion.log"

MASTERIP=$1

#################################################################
# Set up hostname and obtain IP
#################################################################
echo "---start hostname, ip address setup---" | tee -a $LOGFILE 2>&1

yum install curl -y                                                   >> $LOGFILE 2>&1 || { echo "---Failed to install curl---" | tee -a $LOGFILE; exit 1; }
yum install bind-utils -y                                             >> $LOGFILE 2>&1 || { echo "---Failed to install bind-utils---" | tee -a $LOGFILE; exit 1; }

MYIP=$(hostname --ip-address)
echo "---minion node ip address is $MYIP---" | tee -a $LOGFILE 2>&1

MYHOSTNAME=$(dig -x $MYIP +short | sed -e 's/.$//')
echo "---minion node dns hostname is $MYHOSTNAME---" | tee -a $LOGFILE 2>&1

hostnamectl set-hostname $MYHOSTNAME                                  >> $LOGFILE 2>&1 || { echo "---Failed to set hostname---" | tee -a $LOGFILE; exit 1; }

MASTER=$(dig -x $MASTERIP +short | sed -e 's/.$//')
echo "---master node hostname is $MASTER---" | tee -a $LOGFILE 2>&1

echo "---start installing kubernetes minion node on $MYHOSTNAME---" | tee -a $LOGFILE 2>&1 

#################################################################
# install packages
#################################################################
systemctl disable firewalld                                           >> $LOGFILE 2>&1 || { echo "---Failed to disable firewall---" | tee -a $LOGFILE; exit 1; }
systemctl stop firewalld                                              >> $LOGFILE 2>&1 || { echo "---Failed to stop firewall---" | tee -a $LOGFILE; exit 1; }
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config   >> $LOGFILE 2>&1 || { echo "---Failed to config selinux---" | tee -a $LOGFILE; exit 1; }
setenforce 0                                                          >> $LOGFILE 2>&1 || { echo "---Failed to set enforce---" | tee -a $LOGFILE; exit 1; }
yum install flannel -y                                                >> $LOGFILE 2>&1 || { echo "---Failed to install flannel---" | tee -a $LOGFILE; exit 1; }
yum install kubernetes -y                                             >> $LOGFILE 2>&1 || { echo "---Failed to install kubernetes---" | tee -a $LOGFILE; exit 1; }

#################################################################
# configure base kubernetes
#################################################################
echo "---start to write kubernetes config to /etc/kubernetes/config---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://$MASTER:8080"
EOF

#################################################################
# configure flannel to use network defined and stored in etcd
#################################################################
echo "---start to write flannel config to /etc/sysconfig/flanneld---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD_ENDPOINTS="http://$MASTER:2379"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
EOF

#################################################################
# configure flannel to use network defined and stored in etcd
#################################################################
echo "---start to write kublet config to /etc/kubernetes/kubelet---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/kubernetes/kubelet
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_HOSTNAME="--hostname-override=$MYHOSTNAME"
KUBELET_API_SERVER="--api-servers=http://$MASTER:8080"
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
KUBELET_ARGS=""
EOF

#################################################################
# start all the required services
#################################################################
echo "---starting kube-proxy kubelet flanneld docker---" | tee -a $LOGFILE 2>&1
for SERVICES in kube-proxy kubelet flanneld docker; do 
    systemctl restart $SERVICES                                     >> $LOGFILE 2>&1 || { echo "---Failed to restart service---" | tee -a $LOGFILE; exit 1; }
    systemctl enable $SERVICES                                      >> $LOGFILE 2>&1 || { echo "---Failed to enable service---" | tee -a $LOGFILE; exit 1; }
    sleep 5
    systemctl status $SERVICES                                      >> $LOGFILE 2>&1 || { echo "---Failed to check service status---" | tee -a $LOGFILE; exit 1; }
done

echo "---kubernetes minion node installed successfully---" | tee -a $LOGFILE 2>&1 