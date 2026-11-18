output "workspace" {
  value = terraform.workspace
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "virtual_network_name" {
  value = module.network.vnet_name
}

output "subnet_id" {
  value = module.network.subnet_id
}

output "vm_names" {
  value = module.vm.vm_names
}

output "vm_private_ips" {
  value = module.vm.private_ips
}

output "storage_account_names" {
  value = module.storage.storage_account_names
}
