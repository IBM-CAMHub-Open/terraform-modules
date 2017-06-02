################################################################
# Module to install extra services on exisitng VM
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
variable "temp_private_key" {}
variable "temp_public_key" {}
variable "remote_host" {}
variable "module_script" {
  default = "files/default.sh"	
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
variable "remove_temp_private_key" {
  default = "true"
}

resource "null_resource" "default"{

  # Specify the ssh connection
  connection {
    user        = "${var.ssh_user}"
    private_key = "${var.temp_private_key}"
    host        = "${var.remote_host}"
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
      "bash -c 'if [ \"${var.remove_temp_private_key}\" == \"true\" ] ; then KEY=$(echo \"${var.temp_public_key}\" | cut -c 9-); cd /root/.ssh; grep -v $KEY authorized_keys > authorized_keys.new; mv -f authorized_keys.new authorized_keys; chmod 600 authorized_keys; fi'",
      "${var.module_custom_commands}"
    ]
  }
  
}