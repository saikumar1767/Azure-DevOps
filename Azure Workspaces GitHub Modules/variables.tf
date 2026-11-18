# -------------------------
# General
# -------------------------

variable "project" {
  type        = string
  description = "Short project name, used at the start of every resource name"
}

variable "location" {
  type        = string
  description = "Azure region"
}


# -------------------------
# Network
# -------------------------

variable "vnet_address_space" {
  type        = string
  description = "CIDR of the virtual network, e.g. 10.20.0.0/16"
}

variable "subnet_address_prefix" {
  type        = string
  description = "CIDR of the subnet, must be inside the VNet range"
}


# -------------------------
# Virtual Machines
# -------------------------

variable "vm_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

# Not stored in tfvars. Set it in the terminal before plan/apply:
#   $env:TF_VAR_admin_password = "<your password>"
variable "admin_password" {
  type      = string
  sensitive = true
}


# -------------------------
# Storage Accounts
# -------------------------

variable "storage_account_count" {
  type = number
}

variable "storage_account_prefix" {
  type        = string
  description = "Lowercase letters and numbers only. Must be globally unique."
}
