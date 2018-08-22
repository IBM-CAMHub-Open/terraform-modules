########################################################################
# Module to provision one or more VMs
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
########################################################################


#########################################################
# Define the variables
#########################################################
variable "name" {
  description = "Name of the Virtual Machine"
  default     = "None"
}

variable "name_prefix" {
  description = "Name prefix of the Virtual Machines in a cluster"
  default     = "None"
}

variable "folder" {
  description = "Target vSphere folder for Virtual Machine"
  default     = ""
}

variable "datacenter" {
  description = "Target vSphere datacenter for Virtual Machine creation"
  default     = ""
}

variable "vcpu" {
  description = "Number of Virtual CPU for the Virtual Machine"
  default     = 1
}

variable "memory" {
  description = "Memory for Virtual Machine in MBs"
  default     = 1024
}

variable "cluster" {
  description = "Target vSphere Cluster to host the Virtual Machine"
  default     = ""
}

variable "dns_suffixes" {
  description = "Name resolution suffixes for the virtual network adapter"
  type        = "list"
  default     = []
}

variable "dns_servers" {
  description = "DNS servers for the virtual network adapter"
  type        = "list"
  default     = []
}

variable "network_label" {
  description = "vSphere Port Group or Network label for Virtual Machine's vNIC"
}

variable "ipv4_addresses" {
  type        = "list"
  description = "IPv4 addresses for vNIC configuration"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway for vNIC configuration"
}

variable "ipv4_prefix_length" {
  description = "IPv4 Prefix length for vNIC configuration"
}

variable "storage" {
  description = "Data store or storage cluster name for target VMs disks"
  default     = ""
}

variable "vm_template" {
  description = "Source VM or Template label for cloning"
}

variable "ssh_user" {
  description = "The user for ssh connection"
  default     = "root"
}

variable "camc_private_ssh_key" {
  description = "The base64 encoded private key for ssh connection"
  default     = ""
}

variable "user_public_key" {
  description = "User-provided public SSH key used to connect to the virtual machine"
  default     = "None"
}

variable "module_custom_commands" {
  description = "The extra commands needed"
  default     = "sleep 1"
}

variable "count" {
  default = 1
}

##############################################################
# Create Virtual Machines
##############################################################
resource "vsphere_virtual_machine" "vm" {
  count        = "${var.count}"
  name         = "${var.name_prefix == "None" ? var.name : format("${var.name_prefix}-%d", count.index+1)}"
  folder       = "${var.folder}"
  datacenter   = "${var.datacenter}"
  vcpu         = "${var.vcpu}"
  memory       = "${var.memory}"
  cluster      = "${var.cluster}"
  dns_suffixes = "${var.dns_suffixes}"
  dns_servers  = "${var.dns_servers}"
  network_interface {
    label              = "${var.network_label}"
    ipv4_gateway       = "${var.ipv4_gateway}"
    ipv4_address       = "${var.ipv4_addresses[count.index]}"
    ipv4_prefix_length = "${var.ipv4_prefix_length}"
  }
  
  disk {
    datastore = "${var.storage}"
    template  = "${var.vm_template}"
    type      = "thin"
  }

  # Specify the ssh connection
  connection {
    user        = "${var.ssh_user}"
    private_key = "${base64decode(var.camc_private_ssh_key)}"
    host        = "${self.network_interface.0.ipv4_address}"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p .ssh; if [ ! -f .ssh/authorized_keys ] ; then touch .ssh/authorized_keys; chmod 400 .ssh/authorized_keys;fi'",
      "bash -c 'if [ \"${var.user_public_key}\" != \"None\" ] ; then chmod 600 .ssh/authorized_keys; echo \"${var.user_public_key}\" | tee -a $HOME/.ssh/authorized_keys; chmod 400 .ssh/authorized_keys; fi'",
      "${var.module_custom_commands}"
    ]
  }
}

##############################################################
# Output
##############################################################
output "ip" {
  value = "${join(",", vsphere_virtual_machine.vm.*.network_interface.0.ipv4_address)}"     
}

