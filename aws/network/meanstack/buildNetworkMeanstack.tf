############################################################################################
# Terraform Module to create VPC, Internet Gateway, Route Table, Subnet, Security Groups
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
############################################################################################

variable "network_name_prefix" {}

variable "create_meanstack_mongo_security_group" {
  default = true
}

variable "create_meanstack_nodejs_security_group" {
  default = true
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR for the default subnet"
  default     = "10.0.1.0/24"
}

resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.network_name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "${var.network_name_prefix}-gateway"
  }
}

resource "aws_subnet" "default" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  tags {
    Name = "${var.network_name_prefix}-subnet"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name = "${var.network_name_prefix}-route-table"
  }
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${aws_vpc.default.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${aws_subnet.default.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "meanstack_mongo" {
  count       = "${var.create_meanstack_mongo_security_group}"
  name        = "${var.network_name_prefix}-security-group-meanstack-mongo"
  description = "Security group which applies to meanstack servers with mongodb installed "
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.network_name_prefix}-security-group-meanstack-mongo"
  }
}

resource "aws_security_group" "meanstack_nodejs" {
  count       = "${var.create_meanstack_nodejs_security_group}"
  name        = "${var.network_name_prefix}-security-group-meanstack-nodejs"
  description = "Security group which applies to meanstack servers with nodejs/angular/express installed "
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.network_name_prefix}-security-group-meanstack-nodejs"
  }
}

output "subnet_id" {
  value = "${aws_subnet.default.id}"
}

output "meanstack_mongo_security_group_id" {
  value = "${aws_security_group.meanstack_mongo.id}"
}

output "meanstack_nodejs_security_group_id" {
  value = "${aws_security_group.meanstack_nodejs.id}"
}
