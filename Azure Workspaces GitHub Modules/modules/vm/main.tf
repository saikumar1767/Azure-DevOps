# -------------------------
# Network Interfaces (private IP only)
# -------------------------

resource "azurerm_network_interface" "main" {

  count = var.vm_count

  name                = "${var.name_prefix}-vm-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {

    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}


# -------------------------
# Linux Virtual Machines
# -------------------------

resource "azurerm_linux_virtual_machine" "main" {

  count = var.vm_count

  name                = "${var.name_prefix}-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  size = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id
  ]

  os_disk {

    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {

    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = var.tags
}
