module "resource_group" {
  source = "./modules/resource-group"
  resource_group_name = var.resource_group_name
  location = var.location
}

module "storage_account" {
  source = "./modules/storage-account"
  storage_account_name = var.storage_account_name
  location = var.location
  resource_group_name = module.resource_group.resource_group_name   
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  location = var.location
  resource_group_name = module.resource_group.resource_group_name

  vm_name = var.vm_name
  admin_password = var.admin_password
  admin_username = var.admin_username

}