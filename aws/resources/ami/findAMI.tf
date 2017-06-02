#################################################################
# Terraform Module to find AMI
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

variable "aws_region" {}

# Ubuntu 16.04, https://cloud-images.ubuntu.com/locator/
variable "aws_amis" {
  default = {
    us-west-1 = "ami-539ac933"
    us-west-2 = "ami-7c803d1c"
    us-east-1 = "ami-6edd3078"
    us-east-2 = "ami-e0b59085"
  }
}

output "aws_ami" {
  value = "${lookup(var.aws_amis, var.aws_region)}"
}