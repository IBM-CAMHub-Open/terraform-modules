############################################################################################
# Terraform Module to create VPC, Internet Gateway, Route Table, Subnet, Security Groups
# for LAMP stack using MySQL RDS
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
variable "primary_availability_zone" {}
variable "secondary_availability_zone" {}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "primary_subnet_cidr" {
  description = "CIDR for the primary subnet"
  default     = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  description = "CIDR for the secondary subnet"
  default     = "10.0.2.0/24"
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

resource "aws_subnet" "primary" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.primary_subnet_cidr}"
  availability_zone = "${var.primary_availability_zone}"
  tags {
    Name = "${var.network_name_prefix}-subnet"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.secondary_subnet_cidr}"
  availability_zone = "${var.secondary_availability_zone}"
  tags {
    Name = "${var.network_name_prefix}-subnet2"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.network_name_prefix}-db_subnet"
  subnet_ids = ["${aws_subnet.primary.id}", "${aws_subnet.secondary.id}"]
  tags {
    Name = "${var.network_name_prefix}-db_subnet"
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
  subnet_id      = "${aws_subnet.primary.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "application" {
  name        = "${var.network_name_prefix}-security-group-application"
  description = "Security group which applies to lamp application server"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9080
    to_port     = 9080
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
    Name = "${var.network_name_prefix}-security-group-application"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.network_name_prefix}-security-group-database"
  description = "Security group which applies to lamp mysql db"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  } 
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    security_groups = ["${aws_security_group.application.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.network_name_prefix}-security-group-database"
  }
}


output "subnet_id" {
  value = "${aws_subnet.primary.id}"
}

output "application_security_group_id" {
  value = "${aws_security_group.application.id}"
}

output "database_security_group_id" {
  value = "${aws_security_group.database.id}"
}

output "database_subnet_group_name" {
  value = "${aws_db_subnet_group.default.name}"
}