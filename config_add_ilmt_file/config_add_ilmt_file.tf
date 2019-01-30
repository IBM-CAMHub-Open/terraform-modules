resource "null_resource" "create_ilmt_file_dependsOn" {
  provisioner "local-exec" {
    command = "echo The dependsOn output for CAM ILMT swtag id file is ${var.dependsOn}"
  }
}

resource "null_resource" "create_ilmt_file" {

  count = "${var.enable_vm == "true" ? 1 : 0}"

  depends_on = ["null_resource.create_ilmt_file_dependsOn"]

  connection {
    type        = "ssh"
    user        = "${var.vm_os_user}"
    password    = "${var.vm_os_password}"
    private_key = "${var.private_key}"
    host        = "${var.vm_ipv4_address_list[count.index]}"
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${ length(var.bastion_private_key) > 0 ? base64decode(var.bastion_private_key) : var.bastion_private_key}"
    bastion_port        = "${var.bastion_port}"
    bastion_host_key    = "${var.bastion_host_key}"
    bastion_password    = "${var.bastion_password}"            
  }

  provisioner "file" {
    source      = "${path.module}/scripts/create_ilmt_file.sh"
    destination = "/tmp/create_ilmt_file.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/ibm.com_IBM_Cloud_Automation_Manager_managed_system-3.1.0.swidtag"
    destination = "/tmp/ibm.com_IBM_Cloud_Automation_Manager_managed_system-3.1.0.swidtag"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod 755 /tmp/create_ilmt_file.sh",
      "/tmp/create_ilmt_file.sh"
    ]
  }  
}

resource "null_resource" "ilmt_file_created" {
  depends_on = ["null_resource.create_ilmt_file", "null_resource.create_ilmt_file_dependsOn"]

  provisioner "local-exec" {
    command = "echo 'CAM ILMT swtag id file created'" #${var.vm_ipv4_address_list}.'"
  }

}
