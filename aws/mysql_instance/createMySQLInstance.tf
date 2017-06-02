#################################################################
# Terraform Module to create an mySQL instance
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

variable "db_user" {}
variable "db_pwd" {}
variable "db_instance_name" {}
variable "db_security_group_id" {}
variable "db_subnet_group_name" {}
variable "db_storage_size" {}
variable "db_default_az" {}

variable "instance_class" {
	default = "db.t2.micro"
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = "${var.db_storage_size}"
  engine                 = "mysql"
  engine_version         = "5.6.34"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_instance_name}"
  username               = "${var.db_user}"
  password               = "${var.db_pwd}"
  db_subnet_group_name   = "${var.db_subnet_group_name}"
  parameter_group_name   = "default.mysql5.6"
  availability_zone	     = "${var.db_default_az}"
  publicly_accessible    = true
  vpc_security_group_ids = ["${var.db_security_group_id}"]
  skip_final_snapshot    = true
}

output "mysql_address" {
  value = "${aws_db_instance.mysql.address}"
}
