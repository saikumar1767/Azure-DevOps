# -------------------------
# Storage Accounts
# -------------------------
# Name rules: 3-24 characters, lowercase letters and numbers only, globally unique.
# Final name = prefix + workspace + number, e.g. "azdemosadev1"

resource "azurerm_storage_account" "main" {

  count = var.storage_account_count

  name = "${var.storage_account_prefix}${var.env}${count.index + 1}"

  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}
