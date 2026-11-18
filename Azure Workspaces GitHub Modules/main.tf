# -------------------------
# Resource Group
# -------------------------

module "resource_group" {

  source = "git::https://github.com/Bharathreddyd3297/terraform-demo.git//modules/resource-group?ref=v1.0.1"

  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.tags
}


# -------------------------
# Virtual Network + Subnet
# -------------------------

module "network" {

  source = "git::https://github.com/Bharathreddyd3297/terraform-demo.git//modules/network?ref=v1.0.1"

  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix

  tags = local.tags
}


# -------------------------
# Virtual Machines
# -------------------------

module "vm" {

  source = "git::https://github.com/Bharathreddyd3297/terraform-demo.git//modules/vm?ref=v1.0.1"

  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  subnet_id = module.network.subnet_id

  vm_count       = var.vm_count
  vm_size        = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password

  tags = local.tags
}


# -------------------------
# Storage Accounts
# -------------------------

module "storage" {

  source = "git::https://github.com/Bharathreddyd3297/terraform-demo.git//modules/storage?ref=v1.0.1"

  env                 = local.env
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  storage_account_count  = var.storage_account_count
  storage_account_prefix = var.storage_account_prefix

  tags = local.tags
}
