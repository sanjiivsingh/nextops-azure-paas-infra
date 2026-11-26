locals {

  common_tags = merge(var.tags, {
    project     = var.project
    environment = var.environment
  })

  resource_groups = {
    for key, value in var.resource_groups : key => {
      name     = "rg-${var.project}-${var.environment}-${value.name_suffix}"
      location = var.location
      tags     = local.common_tags
    }
  }

  virtual_networks = {
    for key, value in var.virtual_network_config : key => {
      name                = "vnet-${var.project}-${var.environment}-${value.name_suffix}"
      location            = var.location
      address_space       = value.address_space
      resource_group_name = module.resource_group.resource_group_output[value.rg_key].name
      tags                = local.common_tags
    }
  }

  vnet_peerings = merge([
    for key, value in var.virtual_network_config : {

      "${key}-to-${value.remote_vnet_key}" = {
        name                = "peer-${local.virtual_networks[key].name}-to-${local.virtual_networks[value.remote_vnet_key].name}"
        resource_group_name = local.virtual_networks[key].resource_group_name
        source_vnet_key     = key
        remote_vnet_key     = value.remote_vnet_key
      }

      "${value.remote_vnet_key}-to-${key}" = {
        name                = "peer-${local.virtual_networks[value.remote_vnet_key].name}-to-${local.virtual_networks[key].name}"
        resource_group_name = local.virtual_networks[value.remote_vnet_key].resource_group_name
        source_vnet_key     = value.remote_vnet_key
        remote_vnet_key     = key
      }
    }
    if try(value.peering_enabled, false) && try(value.remote_vnet_key, null) != null
  ]...)


  subnets = {
    for key, value in var.subnet_config : key => {
      name                = value.dedicated_subnet ? value.name_suffix : "subnet-${var.project}-${var.environment}-${value.name_suffix}"
      resource_group_name = module.resource_group.resource_group_output[value.rg_key].name
      vnet_key            = value.vnet_key
      address_prefixes = [
        cidrsubnet(
          local.virtual_networks[value.vnet_key].address_space[0],
          value.subnet_prefix - tonumber(
            split("/", local.virtual_networks[value.vnet_key].address_space[0])[1]
          ),
          value.subnet_num
        )
      ]
      delegation_enabled = value.delegation_enabled
      delegation_service = value.delegation_service
    }
  }

  vm_name_prefix = "vm-${var.project}"
  virtual_machine_config = {
    for key, value in var.virtual_machines_config : key => {
      vm_os                 = value.vm_os
      vm_name               = "${local.vm_name_prefix}-${value.vm_name_suffix}"
      resource_group_name   = module.resource_group.resource_group_output[value.rg_key].name
      location              = var.location
      vm_size               = value.vm_size
      admin_username        = data.azurerm_key_vault_secret.vm_username.value
      authentication_method = value.authentication_method
      admin_password        = lower(value.authentication_method) == "password" ? data.azurerm_key_vault_secret.vm_password[0].value : null
      public_key            = lower(value.authentication_method) == "ssh_key" ? data.azurerm_key_vault_secret.ssh_public_key[0].value : null
      subnet_id             = module.hubspokenetwork.subnet_output[value.subnet_key].id
      priority              = value.priority
      eviction_policy       = value.eviction_policy
      max_bid_price         = value.max_bid_price
      public_ip_enabled     = value.public_ip_enabled
      nic_name              = "${local.vm_name_prefix}-${value.vm_name_suffix}-nic"
      nsg_name              = "${local.vm_name_prefix}-${value.vm_name_suffix}-nsg"
      nsg_rules             = value.nsg_rules
    }
  }
  private_dns_zone_config = {
    for key, value in var.private_dns_zone :
    key => {
      name                = "${var.project}-${value.name_suffix}.postgres.database.azure.com"
      resource_group_name = module.resource_group.resource_group_output[value.rg_key].name
      vnet_link_enabled   = value.vnet_link_enabled
      vnet_link_name      = value.vnet_link_enabled ? "${value.name_suffix}-${value.vnet_key}-link" : null
      virtual_network_id  = value.vnet_link_enabled ? module.hubspokenetwork.virtual_network_output[value.vnet_key].id : null
    }
  }

  postgresql_flexible_server_config = {
    for key, value in var.postgresql_flexible_server :
    key => {
      name                          = "${var.project}-${var.environment}-${value.name_suffix}"
      resource_group_name           = module.resource_group.resource_group_output[value.rg_key].name
      location                      = module.resource_group.resource_group_output[value.rg_key].location
      version                       = value.version
      delegated_subnet_id           = module.hubspokenetwork.subnet_output[value.subnet_key].id
      private_dns_zone_id           = module.private_dns_zone[value.private_dns_zone_key].private_dns_zone_output.id
      public_network_access_enabled = value.public_network_access_enabled
      administrator_login           = data.azurerm_key_vault_secret.db_username.value
      administrator_password        = data.azurerm_key_vault_secret.db_password.value
      login_thru_this_pc            = value.login_thru_this_pc
      start_ip_address              = lower(value.login_thru_this_pc) == "yes" ? chomp(data.http.my_ip.response_body) : "0.0.0.0"
      end_ip_address                = lower(value.login_thru_this_pc) == "yes" ? chomp(data.http.my_ip.response_body) : "0.0.0.0"
    }
  }

  webapp_config = {
    for k, v in var.webapp_config :
    k => {
      asp_name                  = v.asp_name
      os_type                   = title(v.os_type)
      sku_name                  = v.sku_name
      resource_group_name       = module.resource_group.resource_group_output[v.rg_key].name
      location                  = module.resource_group.resource_group_output[v.rg_key].location
      name                      = v.name
      public_network_access     = v.public_network_access
      app_type                  = v.app_type
      virtual_network_subnet_id = v.delegated_subnet_key != null ? module.hubspokenetwork.subnet_output[v.delegated_subnet_key].id : null
      runtime_version           = v.runtime_version
      startup_command           = v.startup_command

      app_settings = v.app_type == "node" ? {
        "API_BASE_URL" = format("https://%s.azurewebsites.net", var.webapp_config["backend_webapp"].name)
        "ENVIRONMENT"  = var.environment
        } : {
        "ENVIRONMENT" = var.environment
        "DATABASE_URL" = format(
          "postgresql://%s:%s@%s:5432/%s",
          data.azurerm_key_vault_secret.db_username.value,
          urlencode(data.azurerm_key_vault_secret.db_password.value),
          module.postgresql_flexible_server["psql-server"].psql_output.fqdn,
          var.database_name
        )
      }
    }
  }

}

