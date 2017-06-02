# terraform_modules

This project to develop terraform modules which are re-used across payloads. It also includes scripts which are used in the modules for different payloads.

## Licenses and Copyright

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Licensed Materials - Property of IBM

 ©Copyright IBM Corp. 2017.

## Modules

### ibmcloud

#### virtual_guest

This module is to provision a VM in SoftLayer and run scripts/commands in the newly provisioned VM.

The following scripts/commands executed in the VM sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| hostname |  | The hostname of virtual guest |
| domain |  | The domain of virtual guest |
| datacenter |  | The data center where virtual guest is provisoned |
| os_reference_code |  | The operating system code in SoftLayer |
| cores |  | The number of CPU cores |
| memory |  | The memory size in GB |
| disk1 |  | The size of first disk |
| ssh_user | root | The user for ssh to the virtual guest |
| user_public_key_id |  | The public key specified by customer |
| temp_public_key |  | The public key in the key pair temporarily generated for ssh |
| temp_public_key_id |  | The softlayer id of the temporary public key |
| temp_private_key |  | The private key in the key pair temporarily generated for ssh |
| remove_temp_private_key | true | The flag whether to remove temporary public key from virtual guest |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_variable | "" | The variables of the script to install software |
| module_sample_application_url | "" | The url of sample application tarballs used in the script |
| module_custom_commands | sleep 1 | The custom commands |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| public_ip | The public ip of virtual guest |

#### cluster

This module is to provision a cluster VM in SoftLayer and run scripts/commands in the newly provisioned VMs.

The following scripts/commands executed in the VMs sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| count | 1 | The count of virtual guests to be provisioned |
| hostname |  | The prefix of hostname of virtual guest |
| domain |  | The domain of virtual guest |
| datacenter |  | The data center where virtual guest is provisoned |
| os_reference_code |  | The operating system code in SoftLayer |
| cores |  | The number of CPU cores |
| memory |  | The memory size in GB |
| disk1 |  | The size of first disk |
| ssh_user | root | The user for ssh to the virtual guest |
| user_public_key_id |  | The public key specified by customer |
| temp_public_key |  | The public key in the key pair temporarily generated for ssh |
| temp_public_key_id |  | The softlayer id of the temporary public key |
| temp_private_key |  | The private key in the key pair temporarily generated for ssh |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_variable | "" | The variables of the script to install software |
| module_sample_application_url | "" | The url of sample application tarballs used in the script |
| module_custom_commands | sleep 1 | The custom commands |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| public_ip | The public IPs of virtual guests, separated by comma |

#### null_resource

This module is to run scripts/commands in the newly provisioned VM.

The following scripts/commands executed in the VM sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| remote_host |  | The virtual guest to run the script |
| ssh_user | root | The user for ssh to the virtual guest |
| temp_public_key |  | The public key in the key pair temporarily generated for ssh |
| temp_private_key |  | The private key in the key pair temporarily generated for ssh |
| remove_temp_private_key | true | The flag whether to remove temporary public key from virtual guest |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_variable | "" | The variables of the script to install software |
| module_sample_application_url | "" | The url of sample application tarballs used in the script |
| module_custom_commands | sleep 1 | The custom commands |

### aws
#### ami_instance

This module is to provision a VM in AWS and run script in the newly provisioned VM.

The script will be rendered with variables and then passed to AWS in user_data.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| hostname |  | The hostname of instance |
| aws_ami |  | The amazon machine image |
| aws_instance_type |  | The flavor of instance |
| aws_cam_public_key_id |  | The public key specified by customer |
| aws_subnet_id |  | The id of subnet where the instance is created |
| aws_security_group_id |  | The id of firewall setup for the instance |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_name | default.sh | The name of module script |
| module_script_variable_1 | "" | The first variable of the script to install software |
| module_script_variable_2 | "" | The second variable of the script to install software |
| module_script_variable_3 | "" | The third variable of the script to install software |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| public_ip | The public ip of virtual guest |
| private_ip | The private ip of virtual guest |
| public_dns | The public dns of virtual guest |

#### mysql_instance

This module is to provision a MySQL RDS DB in AWS.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| instance_class | db.t2.micro | The flavor of RDS DB instance |
| db_storage_size |  | The storage size of RDS DB instance |
| db_instance_name |  | The name of RDS DB instance |
| db_default_az |  | The availability zone of RDS DB instance |
| db_subnet_group_name |  | The id of subnet group where the instance is created |
| db_security_group_id |  | The id of firewall setup for the instance |
| db_user |  | The user to access the RDS DB instance |
| db_pwd |  | The user password |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| mysql_address | The FQDN of RDS DB instance |

#### resources
##### ami

#### ami_instance

This module is to retrieve the ami for given region.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| aws_region |  | The region where the instance is created |
| aws_amis | us-west-1 = "ami-539ac933" | The mapping from region to amazon machine images |
|  | us-west-2 = "ami-7c803d1c" |  |
|  | us-east-1 = "ami-6edd3078" |  |
|  | us-east-2 = "ami-e0b59085" |  |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| aws_ami | The retrieved ami |

#### network
##### meanstack

This module is to build the network in AWS, sepcially for Meanstack payload, including
* VPC
* Internet Gateway
* Route Table
* Subnet(s)
* Security Group(s)

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| network_name_prefix |  | The prefix of name tags for the network resources |
| vpc_cidr | 10.0.0.0/16 | The CIDR for the whole VPC |
| private_subnet_cidr | 10.0.1.0/24 | The CIDR for the default subnet |
| create_meanstack_mongo_security_group | true | The flag whether to create security group for mongo instance |
| create_meanstack_nodejs_security_group | true | The flag whether to create security group for nodejs instance |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| subnet_id | The id of subnet |
| meanstack_mongo_security_group_id | The id of security group for mongo instance |
| meanstack_nodejs_security_group_id | The id of security group for nodejs instance |

##### lamp

This module is to build the network in AWS, sepcially for LAMP payload, including
* VPC
* Internet Gateway
* Route Table
* Subnet(s)
* Security Group(s)

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| network_name_prefix |  | The prefix of name tags for the network resources |
| vpc_cidr | 10.0.0.0/16 | The CIDR for the whole VPC |
| primary_subnet_cidr | 10.0.1.0/24 | The CIDR for the primary subnet |
| secondary_subnet_cidr | 10.0.2.0/24 | The CIDR for the second subnet |
| primary_availability_zone |  | The primary availability zone in the network |
| secondary_availability_zone |  | The second availability zone in the network |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| subnet_id | The id of subnet |
| application_security_group_id | The id of security group for application instance |
| database_security_group_id | The id of security group for db instance |
| database_subnet_group_name | The name of subnet group for db instance |

#### null_resource
##### PHP

This module is to run scripts/commands in the newly provisioned instance, specially for apache/php installation.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| public_dns |  | The address of ami instance |
| public_mysql_dns |  | The address of RDS DB instance |
| cam_user |  | The user for ssh |
| cam_pwd |  | The user password for ssh |

### local
#### app_status

This module is to trace the status of application installation.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| script_url | https://raw.githubusercontent.com/camc-experimental/terraform-modules/master/local/app_status/files/checkHttp.sh | The script to check HTTP response |
| script_name | checkHttp.sh | The name of script |
| script_variables | ""  | The variables of script |
| prior_custom_commands | sleep 1 | The custom commands executed before the script |
| posterior_custom_commands | sleep 1 | The custom commands executed after the script |
