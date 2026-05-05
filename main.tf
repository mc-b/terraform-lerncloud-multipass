###
#   Ressourcen
#

resource "null_resource" "multipass" {
  triggers = {
    name = var.module
  }

  # terraform apply
  provisioner "local-exec" {
    command = "multipass launch --name ${var.module} -c${var.cores} -m${var.memory}GB -d${var.storage}GB --cloud-init ${var.userdata} --timeout 1800"
    on_failure = continue    
  }
  provisioner "local-exec" {
    command = "multipass set client.primary-name=${var.module}"
    on_failure = continue
  }

  # terraform destroy - ohne wird VM physikalisch nicht geloescht
  provisioner "local-exec" {
    when    = destroy
    command = "multipass set client.primary-name=primary"

    on_failure = continue
  }  
  provisioner "local-exec" {
    when    = destroy
    command = "multipass delete ${self.triggers.name} --purge"
    on_failure = continue
  }
}