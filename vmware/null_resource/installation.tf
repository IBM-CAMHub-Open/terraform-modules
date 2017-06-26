################################################################
# Module to install applications on exisitng VMs
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
################################################################

variable "ssh_user" {
  default = "root"
}
variable "camc_private_ssh_key" {}
variable "remote_hosts" {
  type    = "list" 
}
variable "module_script" {
  default = "files/default.sh"	
}
variable "module_script_variables" {
  default = ""
}
variable "module_custom_commands" {
  default = "sleep 1"
}

variable "is_dependent_on"{
  default = false
}

variable "count" {
  default = 1
}

resource "null_resource" "default"{
  count        = "${var.count}"
    
  # Specify the ssh connection
  connection {
    user        = "${var.ssh_user}"
    private_key = "${base64decode(var.camc_private_ssh_key)}"
    host        = "${var.remote_hosts[count.index]}"
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
      "bash installation.sh ${var.module_script_variables}",    
      "${var.module_custom_commands}"
    ]
  } 
}

resource "random_id" "default" {
  count = "${var.is_dependent_on}"
  depends_on = ["null_resource.default"]
  byte_length = "8"
}

output "done" {
    value = "${random_id.default.hex}"
}

