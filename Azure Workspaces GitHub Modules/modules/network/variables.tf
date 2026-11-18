variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "subnet_address_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
