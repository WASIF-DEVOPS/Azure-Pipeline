resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "appservice" {
  source                = "./modules/appservies"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  app_service_plan_name = var.app_service_plan_name
  app_service_name      = var.app_service_name
  docker_image          = var.docker_image
}
