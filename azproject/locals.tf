locals {
  vm_instances = flatten([
    for subnet_key in keys(var.mysubnets) : [
      for i in range(2) : {
        name       = "vm-${subnet_key}-${i}"
        subnet_key = subnet_key
      }
    ]
  ])
}