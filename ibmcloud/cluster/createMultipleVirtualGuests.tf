########################################################################
# Module to deploy multiple VMs with specified applications installed
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
variable "hostname" {}
variable "datacenter" {}
variable "user_public_key_id" {}
variable "temp_public_key_id" {}
variable "temp_public_key" {}
variable "temp_private_key" {}
variable "module_script" {
  default = "files/default.sh"
}
variable "os_reference_code" {}
variable "domain" {}
variable "cores" {}
variable "memory" {}
variable "disk1" {}
variable "count" {
  default = 1
}
variable "ssh_user" {
  default = "root"
}
variable "module_script_variables" {
  default = ""
}
variable "module_sample_application_url" {
  default = ""
}
variable "module_custom_commands" {
  default = "sleep 1"
}

resource "ibmcloud_infra_virtual_guest" "softlayer_virtual_guest" {
  count                    = "${var.count}"
  hostname                 = "${var.hostname}-${count.index+1}"
  os_reference_code        = "${var.os_reference_code}"
  domain                   = "${var.domain}"
  datacenter               = "${var.datacenter}"
  network_speed            = 10
  hourly_billing           = true
  private_network_only     = false
  cores                    = "${var.cores}"
  memory                   = "${var.memory}"
  disks                    = ["${var.disk1}"]
  dedicated_acct_host_only = true
  local_disk               = false
  ssh_key_ids              = ["${var.user_public_key_id}", "${var.temp_public_key_id}"]

  # Specify the ssh connection
  connection {
    user        = "${var.ssh_user}"
    private_key = "${var.temp_private_key}"
    host        = "${self.ipv4_address}"
  }
  
  # Create the installation script
  provisioner "file" {
    source      = "${path.module}/${var.module_script}"
    destination = "installation.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x installation.sh",
      "bash installation.sh ${var.module_sample_application_url} ${var.module_script_variables}",
      "bash -c 'KEY=$(echo \"${var.temp_public_key}\" | cut -c 9-); cd /root/.ssh; grep -v $KEY authorized_keys > authorized_keys.new; mv -f authorized_keys.new authorized_keys; chmod 600 authorized_keys'",
      "${var.module_custom_commands}"
    ]
  }
}

output "public_ip" {
    value = "${join(",", ibmcloud_infra_virtual_guest.softlayer_virtual_guest.*.ipv4_address)}"    
}