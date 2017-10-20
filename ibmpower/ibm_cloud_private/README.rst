=======
Summary
=======

This Terraform sample will perform a simple IBM Cloud private (ICP) deployment
using the Community Edition. It is currently setup to deploy an ICP master node
(also serves as the boot and proxy node) and a user-configurable number of ICP
worker nodes. This sample does not supersede the official ICP deployment
instructions, it merely serves as a simple way to provision an ICP cluster
within your infrastructure for experimental purposes.

Assumptions
-----------
* It is assumed that the reader is already familiar with IBM Cloud private;
  if you are not, please refer to the `ICP Community
  <https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W1559b1be149d_43b0_881e_9783f38faaff>`_
* It is assumed that the reader is already familiar with Terraform; if you
  are not, there are a lot of great articles available on the web or you can
  read this PowerVC `blog post
  <https://developer.ibm.com/powervc/2017/06/29/infrastructure-code-terraform-meets-powervc/>`_

Prerequisites
-------------
* You have `downloaded Terraform
  <https://www.terraform.io/downloads.html>`_ and installed it on your workstation
* You have an instance of PowerVC 1.3.3 (or newer) running
* You have an Ubuntu 16.04 (or newer) image loaded within PowerVC; this will be
  used as the baseline virtual machine for all of the ICP nodes

Instructions
------------
* Download all of the files in this directory and place them in an ICP
  directory on your Terraform workstation
* On your Terraform workstation, generate an SSH key pair to be pushed (via
  Terraform) to all of the nodes; e.g., you can [**ssh-keygen -t rsa**] to
  create this from a Linux or macOS workstation (this will be referenced in
  the subsequent step when you're updating **variables.tf**)
* Edit the contents of **variables.tf** to align with your PowerVC deployment
  (make sure you're using an OpenStack flavor with sufficient resources; a
  minimum of 2 vcpus and 8 GB of memory is recommended)
* Within **bootstrap_icp_master.sh**, change the ICP version tag to align with
  whatever release of ICP that you want to deploy
* Within **ibm-icp-deploy.tf**, change the value of the "count" variable to the
  number of ICP worker nodes that you want to deploy; note that if you're
  using this for anything beyond a proof-of-concept, please also take the
  added step of setting *insecure=false* and set the *cacert* option to the
  contents of the PowerVC certificate (*/etc/pki/tls/certs/powervc.crt*)
* Run [**terraform apply -parallelism=2**] to start the ICP deployment
* Sit back and relax... within about 20-30 minutes, you should be able to
  access your ICP cluster at https://<ICP_MASTER_IP_ADDRESS>:8443
