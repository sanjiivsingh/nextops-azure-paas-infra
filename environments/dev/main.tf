module "resource_group" {
  source = "../../modules/resource group"

  resource_group_config = local.resource_groups
}

module "hubspokenetwork" {
  source = "../../modules/hub and spoke network"

  virtual_network_config = local.virtual_networks
  subnet_config          = local.subnets
  vnet_peering_config    = local.vnet_peerings
}

module "virtual_machines" {
  source                         = "../../modules/virtual machine"
  for_each                       = local.virtual_machine_config
  virtual_machine_config = each.value
}

module "private_dns_zone" {
  for_each = local.private_dns_zone_config
  source = "../../modules/private dns zone "
  private_dns_zone_config = each.value
}

module "postgresql_flexible_server" {
  source = "../../modules/database for postgreSQL "
  for_each = local.postgresql_flexible_server_config
  postgresql_flexible_server_config = each.value
}