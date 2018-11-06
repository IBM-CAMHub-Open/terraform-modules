<!---
Copyright IBM Corp. 2018, 2018
--->

# Add ILMT CAM swtag id Module

The config_add_ilmt_file module sets on the deployed virtual machine the IBM License Metric Tool (ILMT) license file for CAM.

The module must be executed on any vms deployed using CAM in order to register the deployment with the ILMT license tool.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dependsOn | Boolean for dependency | string | `true` | no |
| enable_vm | Boolean for vm creation | string | `true` | no |
| private_key | Private SSH key Details to the Virtual machine | string | - | yes |
| vm_ipv4_address_list | IPv4 Address's in List format | list | - | yes |
| vm_os_password | Operating System Password for the Operating System User to access virtual machine | string | - | yes |
| vm_os_user | Operating System user for the Operating System User to access virtual machine | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dependsOn | Output Parameter when Module Completes |


To use the module in your deployment, include the following module definition in your main terraform template: 

## Sample usage

```
module "add_ilmt_file" {
  source               = "git::https://github.com/IBM-CAMHub-Open/terraform-modules.git?ref=1.0//config_add_ilmt_file"
  
  enable_vm           = "false"

  private_key          = ""
  vm_os_password       = ""
  vm_os_user           = ""
  vm_ipv4_address_list = ""
  #######
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
  #######    
  dependsOn            = "${module.deployVM.dependsOn}"
}
```

In the above sample usage, the module requires:

**VM is enabled**:
- *enable_vm* = optional property, set it to false if the vm this module depends on will not be created.  The default value of the *enable_vm* is true so there is no need to set it for configurations that create the depending vm.

**Virtual machine connection information**:
- *private_key* = vm's private key ( can be empty if password is used instead )
- *vm_os_password* = vm's os password ( can be empty if private key is used to communicate with the vm )
- *vm_os_user* - vm's os user, required
- *vm_ipv4_address_list* = ip of the vm

**When running behind a firewall**:
- *bastion* information if the vm is using a bastion host. The bastion properties can be empty if no bastion host is being used

**Module dependency on terraform deploy**:
- *dependsOn* - boolean variable used to set dependencies between modules. The module should run only after the vm has been created so make sure the module creating the vm defines a boolean variable that can be used as input for the config_add_ilmt_file dependsOn variable. In the sample code above, the vm is created by the deployVM module, which defines a boolean variable also called dependsOn. We use the module.deployVM.dependsOn as input for config_add_ilmt_file dependsOn variable to build the modules dependencies.

## Other templates using this module

This module is currently being used by the CAM ICP modules to register the ICP deployed vms with the ILMT tool.
You can use these templates as samples on how to include the config_add_ilmt_file module in your terraform templates.

ICP templates using the *config_add_ilmt_file* module :

https://github.com/IBM-CAMHub-Open/template_icp_installer_single

https://github.com/IBM-CAMHub-Open/template_icp_installer_medium


