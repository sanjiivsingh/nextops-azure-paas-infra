resource "azurerm_subnet" "this" {
  for_each             = var.subnet_config
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes
  dynamic "delegation" {
    for_each = each.value.delegation_enabled ? [1] : []

    content {
      name = "service-delegation"

      service_delegation {
        name = each.value.delegation_service

        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }
}

