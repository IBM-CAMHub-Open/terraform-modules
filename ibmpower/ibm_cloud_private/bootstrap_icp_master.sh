#!/bin/bash

################################################################
# Module to deploy IBM Cloud private
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
################################################################

# Version of IBM Cloud private to install
ICP_VER=1.2.0

# Disable the firewall
/usr/sbin/ufw disable
# Enable NTP
/usr/bin/timedatectl set-ntp on
# Need to set vm.max_map_count to at least 262144
/sbin/sysctl -w vm.max_map_count=262144
# Prepare the system for updates, install Docker and install Python
/usr/bin/apt update
/usr/bin/apt-get --assume-yes install docker.io
/usr/bin/apt-get --assume-yes install python
/usr/bin/apt-get --assume-yes install interchange
/bin/systemctl start docker

# Ensure the hostnames are resolvable
IP=`/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
/bin/echo "${IP} $(hostname)" >> /etc/hosts

# Configure IBM Cloud private
/usr/bin/docker pull ppc64le/cfc-installer:${ICP_VER}
/bin/mkdir /opt/ibm-cloud-private-ce-${ICP_VER}
cd /opt/ibm-cloud-private-ce-${ICP_VER}
/usr/bin/docker run -e LICENSE=accept -v \
    "$(pwd)":/data ppc64le/cfc-installer:${ICP_VER} cp -r cluster /data

# Configure the master and proxy as the same node
/bin/echo "[master]"  > cluster/hosts
/bin/echo "${IP}"    >> cluster/hosts
/bin/echo "[proxy]"  >> cluster/hosts
/bin/echo "${IP}"    >> cluster/hosts
# Configure the worker node(s)
for worker_ip in $( cat /root/icp_worker_nodes.txt | sed 's/|/\n/g' ); do
    /bin/echo "[worker]"     >> cluster/hosts
    /bin/echo "${worker_ip}" >> cluster/hosts
done

# Setup the private key for the ICp cluster (injected at deploy time)
/bin/cp /root/id_rsa.terraform \
    /opt/ibm-cloud-private-ce-${ICP_VER}/cluster/ssh_key
/bin/chmod 400 /opt/ibm-cloud-private-ce-${ICP_VER}/cluster/ssh_key

# Deploy IBM Cloud private
cd /opt/ibm-cloud-private-ce-${ICP_VER}/cluster
/usr/bin/docker run -e LICENSE=accept --net=host -t -v \
    "$(pwd)":/installer/cluster ppc64le/cfc-installer:${ICP_VER} install

exit 0
