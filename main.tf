###
#   Ressourcen
#

resource "local_file" "cloud_init" {
  for_each = var.machines

  content  = each.value.userdata
  filename = "${path.module}/tmp/${each.key}-cloud-init.yaml"
}

variable "machines" {
  type = map(object({
    hostname    = string
    description = optional(string)
    userdata    = string
  }))
}

resource "null_resource" "multipass" {
  for_each = var.machines

  triggers = {
    name = each.key
  }

  provisioner "local-exec" {
    command    = "multipass launch --name ${each.key} -c${var.cores} -m${var.memory}GB -d${var.storage}GB --cloud-init ${local_file.cloud_init[each.key].filename}"
    on_failure = continue
  }

  provisioner "local-exec" {
    command    = "multipass set client.primary-name=${each.key}"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "multipass set client.primary-name=primary"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "multipass delete ${each.key} --purge"
    on_failure = continue
  }
}
