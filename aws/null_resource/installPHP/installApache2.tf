################################################################
# Module to install php
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

variable "public_dns" {}
variable "public_mysql_dns" {}
variable "cam_user" {}
variable "cam_pwd" {}

data "template_file" "mpm_prefork" {
  template = "${file("${path.module}/files/mpm_prefork.conf")}"
}
 
data "template_file" "virtualHost" {
  template = "${file("${path.module}/files/virtualHost.conf")}"
  vars {
    public_dns = "${var.public_dns}"
  }
}

data "template_file" "helloworld" {
  template = "${file("${path.module}/files/helloworld.html")}"
  vars {
    public_dns = "${var.public_dns}"
  }
}

resource "null_resource" "apache2" {
  connection {
    host = "${var.public_dns}"
    user = "${var.cam_user}"
    password = "${var.cam_pwd}" 
  }

  #rendering script files with variables is a bit tricky, so xfer script and pass args vs templating
  provisioner "file" {
    source = "${path.module}/files/setupApache2.sh"
    destination = "/tmp/setupApache2.sh"
  }
    
  provisioner "file" {
    source = "${path.module}/files/test.php"
    destination = "/tmp/test.php"
  }    

  # single quote no interpolation
  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'mkdir /tmp/apache2'",
      "sudo sh -c 'echo \"${data.template_file.mpm_prefork.rendered}\" > /tmp/apache2/mpm_prefork.conf'",
      "sudo sh -c 'echo \"${data.template_file.virtualHost.rendered}\" > /tmp/apache2/${var.public_dns}.conf'",
      "sudo sh -c 'echo \"${data.template_file.helloworld.rendered}\" > /tmp/apache2/helloworld.html'",
      "sudo sh -c 'mv /tmp/setupApache2.sh /tmp/apache2/setupApache2.sh'", 
      "sudo sh -c 'mv /tmp/test.php /tmp/apache2/test.php'",     		
      "sudo sh -c 'chown root:root /tmp/apache2/*'",  
      "sudo sh -c 'chmod +x /tmp/apache2/setupApache2.sh'",
      "sudo sh -c \"/tmp/apache2/setupApache2.sh ${var.public_dns} ${var.public_mysql_dns} ${var.cam_user} ${var.cam_pwd}\""
    ]
  }	
}
