
resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.postgresql_flexible_server_config.name
  resource_group_name = var.postgresql_flexible_server_config.resource_group_name
  location            = var.postgresql_flexible_server_config.location
  version             = var.postgresql_flexible_server_config.version

  public_network_access_enabled = var.postgresql_flexible_server_config.public_network_access_enabled
  delegated_subnet_id           = var.postgresql_flexible_server_config.public_network_access_enabled ? null : var.postgresql_flexible_server_config.delegated_subnet_id
  private_dns_zone_id           = var.postgresql_flexible_server_config.public_network_access_enabled ? null : var.postgresql_flexible_server_config.private_dns_zone_id
  administrator_login           = var.postgresql_flexible_server_config.administrator_login
  administrator_password        = var.postgresql_flexible_server_config.administrator_password
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = "GP_Standard_D2s_v3"


}
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  count            = var.postgresql_flexible_server_config.public_network_access_enabled ? 1 : 0
  name             = "allow-my-pc"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = var.postgresql_flexible_server_config.start_ip_address
  end_ip_address   = var.postgresql_flexible_server_config.end_ip_address
}
