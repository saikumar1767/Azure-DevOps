# -------------------------
# DEV values  ->  use with:  terraform workspace select dev
#                            terraform apply -var-file="dev.tfvars"
# -------------------------

project  = "azgh"
location = "Central India"

# Network
vnet_address_space    = "10.20.0.0/16"
subnet_address_prefix = "10.20.1.0/24"

# Virtual Machines
vm_count       = 1
vm_size        = "Standard_B1s"
admin_username = "azureuser"

# Storage Accounts
storage_account_count  = 1
storage_account_prefix = "azghsa"
