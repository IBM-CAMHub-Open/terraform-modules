################################################################
# Module to deploy php in day 2
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
variable "ip_address" {}
variable "cam_user" {}
variable "cam_pwd" {}
variable "php_file" {}
variable "script" {}


resource "null_resource" "application" {
	connection {
		host = "${var.public_dns}"
		user = "${var.cam_user}"
		password = "${var.cam_pwd}" 
	}
    
    provisioner "file" {
        source = "${path.module}/files/${var.php_file}"
        destination = "/tmp/${var.php_file}"
    }
    
    provisioner "file" {
        source = "${path.module}/files/${var.script}"
        destination = "/tmp/${var.script}"
    }         

	# single quote no interpolation
	provisioner "remote-exec" {
    	inline = [
    		"sudo sh -c 'mkdir /tmp/application'",
    		"sudo sh -c \"mv /tmp/${var.script} /tmp/application/${var.script}\"", 
    		"sudo sh -c \"mv /tmp/${var.php_file} /tmp/application/${var.php_file}\"",     		
     		"sudo sh -c 'chown root:root /tmp/application/*'",  
    		"sudo sh -c \"chmod +x /tmp/application/${var.script}\"",
    		"sudo sh -c \"/tmp/application/${var.script} ${var.public_mysql_dns} ${var.cam_user} ${var.cam_pwd} ${var.php_file} ${var.public_dns}\""
   		]
  	}	
}
