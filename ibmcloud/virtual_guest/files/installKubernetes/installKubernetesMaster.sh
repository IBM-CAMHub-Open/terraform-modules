#!/bin/bash
#################################################################
# Script to install Kubernetes Single Master Node
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

LOGFILE="/var/log/install_kubernetes_master.log"

#################################################################
# Set up hostname and obtain IP
#################################################################
echo "---start hostname, ip address setup---" | tee -a $LOGFILE 2>&1
yum install curl -y                                                   >> $LOGFILE 2>&1 || { echo "---Failed to install curl---" | tee -a $LOGFILE; exit 1; }
yum install bind-utils -y                                             >> $LOGFILE 2>&1 || { echo "---Failed to install bind-utils---" | tee -a $LOGFILE; exit 1; }

MYIP=$(hostname --ip-address)
echo "---master node ip address is $MYIP---" | tee -a $LOGFILE 2>&1

MYHOSTNAME=$(dig -x $MYIP +short | sed -e 's/.$//')
echo "---master node dns hostname is $MYHOSTNAME---" | tee -a $LOGFILE 2>&1

hostnamectl set-hostname $MYHOSTNAME                                  >> $LOGFILE 2>&1 || { echo "---Failed to set hostname---" | tee -a $LOGFILE; exit 1; }
echo "---start installing kubernetes master node on $MYHOSTNAME---" | tee -a $LOGFILE 2>&1 

#################################################################
# install packages
#################################################################
systemctl disable firewalld                                           >> $LOGFILE 2>&1 || { echo "---Failed to disable firewall---" | tee -a $LOGFILE; exit 1; }
systemctl stop firewalld                                              >> $LOGFILE 2>&1 || { echo "---Failed to stop firewall---" | tee -a $LOGFILE; exit 1; }
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config   >> $LOGFILE 2>&1 || { echo "---Failed to config selinux---" | tee -a $LOGFILE; exit 1; }
setenforce 0                                                          >> $LOGFILE 2>&1 || { echo "---Failed to set enforce---" | tee -a $LOGFILE; exit 1; }
yum install etcd -y                                                   >> $LOGFILE 2>&1 || { echo "---Failed to install etcd---" | tee -a $LOGFILE; exit 1; }
yum install flannel -y                                                >> $LOGFILE 2>&1 || { echo "---Failed to install flannel---" | tee -a $LOGFILE; exit 1; }
yum install kubernetes -y                                             >> $LOGFILE 2>&1 || { echo "---Failed to install kubernetes---" | tee -a $LOGFILE; exit 1; }

#################################################################
# configure etcd
#################################################################
echo "---start to write etcd config to /etc/etcd/etcd.conf---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/etcd/etcd.conf
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
EOF

#################################################################
# start etcd and define flannel network
#################################################################
echo "---starting etcd and using etcdctl mk---" | tee -a $LOGFILE 2>&1
systemctl start etcd                                                 >> $LOGFILE 2>&1 || { echo "---Failed to start etcd---" | tee -a $LOGFILE; exit 1; }
systemctl status etcd                                                >> $LOGFILE 2>&1 || { echo "---Failed to check etcd status---" | tee -a $LOGFILE; exit 1; }                        
sleep 5
etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'   >> $LOGFILE 2>&1 || { echo "---Failed to run etcdctl---" | tee -a $LOGFILE; exit 1; }

#################################################################
# configure kubernetes apiserver
#################################################################
echo "---start to write apiserver config to /etc/kubernetes/apiserver---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/kubernetes/apiserver
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_ETCD_SERVERS="--etcd-servers=http://$MYHOSTNAME:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.10.10.0/24"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota"
KUBE_API_ARGS=""
EOF

#################################################################
# configure base kubernetes
#################################################################
echo "---start to write kubernetes config to /etc/kubernetes/config---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://$MYHOSTNAME:8080"
EOF

#################################################################
# configure flannel to use network defined and stored in etcd
#################################################################
echo "---start to write flannel config to /etc/sysconfig/flanneld---" | tee -a $LOGFILE 2>&1
cat << EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD_ENDPOINTS="http://$MYHOSTNAME:2379"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
EOF

#################################################################
# start all the required services
#################################################################
echo "---starting etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy docker flanneld---" | tee -a $LOGFILE 2>&1
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy docker flanneld; do 
    systemctl restart $SERVICES                                    >> $LOGFILE 2>&1 || { echo "---Failed to restart service---" | tee -a $LOGFILE; exit 1; }
    systemctl enable $SERVICES                                     >> $LOGFILE 2>&1 || { echo "---Failed to enable service---" | tee -a $LOGFILE; exit 1; }
    sleep 5
    systemctl status $SERVICES                                     >> $LOGFILE 2>&1 || { echo "---Failed to check service status---" | tee -a $LOGFILE; exit 1; }
done

#################################################################
# install the kubernetes-dashboard
#################################################################
echo "---install the kubernetes-dashboard---" | tee -a $LOGFILE 2>&1

curl -O https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml                                    >> $LOGFILE 2>&1 || { echo "---Failed to download kubernetes dashboard yaml---" | tee -a $LOGFILE; exit 1; }
sed -i "s/# - --apiserver-host=http:\/\/my-address:port/- --apiserver-host=http:\/\/$MYIP:8080/g" kubernetes-dashboard.yaml    >> $LOGFILE 2>&1 || { echo "---Failed to update kubernetes dashboard yaml---" | tee -a $LOGFILE; exit 1; }

kubectl create -f kubernetes-dashboard.yaml --validate=false                                                                   >> $LOGFILE 2>&1  
echo "---kubernetes master node installed successfully---" | tee -a $LOGFILE 2>&1


#################################################################
# reboot
#################################################################
#echo "---reboot required to enable networking model---" | tee -a $LOGFILE 2>&1
#reboot
