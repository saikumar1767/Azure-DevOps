output "vm_names" {
  value = azurerm_linux_virtual_machine.main[*].name
}

output "vm_ids" {
  value = azurerm_linux_virtual_machine.main[*].id
}

output "private_ips" {
  value = azurerm_network_interface.main[*].private_ip_address
}
