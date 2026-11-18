variable "env" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_count" {
  type = number
}

variable "storage_account_prefix" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.storage_account_prefix))
    error_message = "The storage_account_prefix must be 3-16 lowercase letters or numbers."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
