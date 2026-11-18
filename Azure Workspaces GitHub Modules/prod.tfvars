# -------------------------
# PROD values  ->  use with:  terraform workspace select prod
#                             terraform apply -var-file="prod.tfvars"
# -------------------------

project  = "azgh"
location = "Central India"

# Network
vnet_address_space    = "10.30.0.0/16"
subnet_address_prefix = "10.30.1.0/24"

# Virtual Machines
vm_count       = 2
vm_size        = "Standard_B2s"
admin_username = "azureuser"

# Storage Accounts
storage_account_count  = 2
storage_account_prefix = "azghsa"
