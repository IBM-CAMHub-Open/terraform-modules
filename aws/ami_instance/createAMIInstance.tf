#################################################################################################
# Terraform Module to create an AWS server and run a script
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
#################################################################################################

variable "aws_ami" {}
variable "aws_subnet_id" {}
variable "aws_security_group_id" {}
variable "aws_cam_public_key_id" {}
variable "hostname" {}
variable "aws_instance_type" {}
variable "module_script" {
  default = "files/default.sh"	
}
variable "module_script_name" {
  default = "default.sh"	
}
variable "module_script_variable_1" {
  default = ""	
}
variable "module_script_variable_2" {
  default = ""	
}
variable "module_script_variable_3" {
  default = ""	
}

data "template_file" "default" {
  template = "${file("${path.module}/${var.module_script}")}"
  vars {
    variable_1 = "${var.module_script_variable_1}"
    variable_2 = "${var.module_script_variable_2}"
    variable_3 = "${var.module_script_variable_3}"
  }
}

data "template_cloudinit_config" "default" {
  part {
    content_type = "text/x-shellscript"
    filename     = "${var.module_script_name}"
    content      = "${data.template_file.default.rendered}"
  }
}

resource "aws_instance" "cam_server" {
  instance_type               = "${var.aws_instance_type}" 
  ami                         = "${var.aws_ami}"
  subnet_id                   = "${var.aws_subnet_id}"
  vpc_security_group_ids      = ["${var.aws_security_group_id}"]
  key_name                    = "${var.aws_cam_public_key_id}"
  associate_public_ip_address = true
  user_data                   = "${data.template_cloudinit_config.default.rendered}"
  tags {
    Name = "${var.hostname}"
  }
}

output "public_ip" {
  value = "${aws_instance.cam_server.public_ip}"
}
output "private_ip" {
  value = "${aws_instance.cam_server.private_ip}"
}
output "public_dns" {
  value = "${aws_instance.cam_server.public_dns}"
}