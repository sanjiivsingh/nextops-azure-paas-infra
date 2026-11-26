# App Service Plan (Linux)

resource "azurerm_service_plan" "asp" {

  name                = var.webapp_config.asp_name
  resource_group_name = var.webapp_config.resource_group_name
  location            = var.webapp_config.location
  os_type             = var.webapp_config.os_type
  sku_name            = var.webapp_config.sku_name

}


# Linux Web App

resource "azurerm_linux_web_app" "webapp" {

  name                          = var.webapp_config.name
  resource_group_name           = var.webapp_config.resource_group_name
  location                      = var.webapp_config.location
  service_plan_id               = azurerm_service_plan.asp.id
  public_network_access_enabled = var.webapp_config.public_network_access
  https_only                    = true
  virtual_network_subnet_id     = var.webapp_config.virtual_network_subnet_id
  site_config {
    always_on = true
    vnet_route_all_enabled = (
      var.webapp_config.virtual_network_subnet_id != null
    )
    # Application Stack

    dynamic "application_stack" {
      for_each = [var.webapp_config]

      content {
        node_version   = application_stack.value.app_type == "node" ? application_stack.value.runtime_version : null
        python_version = application_stack.value.app_type == "python" ? application_stack.value.runtime_version : null
      }

    }

    #  startup command
    app_command_line = var.webapp_config.startup_command
  }

  # Stack-specific and custom environment variables

  app_settings = local.final_app_settings

}
