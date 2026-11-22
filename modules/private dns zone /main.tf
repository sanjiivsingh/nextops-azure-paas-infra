resource "azurerm_private_dns_zone" "this" {
  name                = var.private_dns_zone_config.name
  resource_group_name = var.private_dns_zone_config.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count               = var.private_dns_zone_config.vnet_link_enabled ? 1 : 0
  name                = var.private_dns_zone_config.vnet_link_name
  private_dns_zone_id = azurerm_private_dns_zone.this.id
  virtual_network_id  = var.private_dns_zone_config.virtual_network_id
}
