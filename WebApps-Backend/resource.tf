

resource "azurerm_linux_web_app" "amexwebapp" {
  name = var.webapp
    resource_group_name = azurerm_resource_group.amexrg.name
  location = azurerm_resource_group.amexrg.location
  service_plan_id = azurerm_service_plan.amexasp.id
  site_config {
  }
}

resource "azurerm_service_plan" "amexasp" {
  name = var.asp
  resource_group_name = azurerm_resource_group.amexrg.name
  location = azurerm_resource_group.amexrg.location
  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_resource_group" "amexrg" {
  name = var.rgname
  location = var.location
}


resource "azurerm_service_plan" "amexasp2" {
  name = "amexasp2"
  resource_group_name = azurerm_resource_group.amexrg.name
  location = azurerm_resource_group.amexrg.location
  os_type = "Linux"
  sku_name = "B1"
}