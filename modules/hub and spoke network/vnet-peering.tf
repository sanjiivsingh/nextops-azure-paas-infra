resource "azurerm_virtual_network_peering" "this" {
  for_each                     = var.vnet_peering_config
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = azurerm_virtual_network.this[each.value.source_vnet_key].name
  remote_virtual_network_id    = azurerm_virtual_network.this[each.value.remote_vnet_key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
