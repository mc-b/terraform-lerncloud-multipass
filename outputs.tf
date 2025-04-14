###
#   Outputs wie IP-Adresse und DNS Name
#  

output "ip_vm" {
  description = "Map mit IP-Adressen aller VMs"
  value = {
    for name in keys(var.machines) :
    name => chomp(trimspace(
      join("", [
        for line in split("\n", 
          try(
            trimspace(
              replace(
                replace(
                  replace(
                    join("", [
                      for command in [
                        "multipass info ${name} | grep IPv4 | awk '{print $2}'"
                      ] : "${command}"
                    ]),
                    "\n", ""
                  ),
                  "\r", ""
                ),
                " ", ""
              )
            ), 
            "0.0.0.0"
          )
        ) : line
      ])
    ))
  }
}

output "fqdn_vm" {
  description = "Map mit FQDNs aller VMs"
  value = {
    for name in keys(var.machines) :
    name => format("%s.mshome.net", name)
  }
}

output "fqdn_private" {
  description = "Map mit FQDNs aller VMs"
  value = {
    for name in keys(var.machines) :
    name => format("%s.mshome.net", name)
  }
}

output "description" {
  description = "Map mit Beschreibung der VMs"
  value = {
    for name, machine in var.machines :
    name => lookup(machine, "description", "")
  }
}
