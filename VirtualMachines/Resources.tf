resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  name = "rg-${each.key}"
  location = var.location

lifecycle {
  ignore_changes = [ tags ]
}


}

resource "azurerm_virtual_network" "vnet" {
  for_each = var.environments
  name = "vnet-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
    # dev = 10.1.0.0/16
    # qa = 10.2.0.0/16
    # prod = 10.3.0.0/16

  address_space = [ 
    "10.${each.key == "dev" ? 1 : each.key == "qa" ? 2 : 3}.0.0/16"
   ]

   depends_on = [ azurerm_resource_group.rg ]
}


resource "azurerm_subnet" "snet" {
  for_each = var.environments
  name = "subnet-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes = [ 
    "10.${each.key == "dev" ? 1 : each.key == "qa" ? 2 : 3}.1.0/24"
   ]
}

resource "azurerm_public_ip" "pip" {
  for_each = var.environments
  name = "pip-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method = "Static"
  lifecycle {
    create_before_destroy = true
  }

}

resource "azurerm_network_interface" "nic" {
  for_each = var.environments
  name = "nic-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  ip_configuration {
    name = "ipconfig-${each.key}"
    subnet_id = azurerm_subnet.snet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
    depends_on = [ azurerm_public_ip.pip, azurerm_subnet.snet ]

}

resource "azurerm_linux_virtual_machine" "VM" {
  for_each = var.environments
  name = "vm-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  size = each.value
  admin_username = var.adminusername
  admin_ssh_key {
    username = var.adminusername
    public_key = file(var.ssh_publickey_path)
  }
   disable_password_authentication = true
   os_disk {
     name = "osdisk-${each.key}"
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }
   network_interface_ids = [ azurerm_network_interface.nic[each.key].id ]

   source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server" # or "server" for Gen2 VMs
    version   = "latest"       # Automatically pulls the latest release
  }

  lifecycle {
    ignore_changes = [ size,tags ]
  }

}


resource "azurerm_resource_group" "countdemo" {
  count = 2
  name = "Count-rg-${count.index + 1}"

#   count.0--> 0+1 = 1
#   count.1--> 1+1 = 2
    location = var.location
}


