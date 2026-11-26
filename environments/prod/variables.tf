variable "project" {
  type        = string
  description = "Name of the Project"
}

variable "environment" {
  type        = string
  description = "Configuration for the Environment"
}

variable "location" {
  type = string
}

variable "tags" {
  type        = map(any)
  description = "Tags for the resources"
}

variable "resource_groups" {
  type = map(object({
    name_suffix = string
  }))
}

variable "virtual_network_config" {
  type = map(object({
    name_suffix     = string
    rg_key          = string
    address_space   = list(string)
    peering_enabled = optional(bool, false)
    remote_vnet_key = optional(string, null)
  }))
}

variable "subnet_config" {
  type = map(object({
    name_suffix                       = string
    rg_key                            = string
    vnet_key                          = string
    dedicated_subnet                  = optional(bool, false)
    subnet_num                        = number
    subnet_prefix                     = number
    private_endpoint_network_policies = optional(string, "Disabled")
    delegation_enabled                = optional(bool, false)
    delegation_service                = optional(string, null)
  }))
}
variable "virtual_machines_config" {
  description = "Configuration for the Windows virtual machine"
  type = map(object({
    vm_os                 = string
    vm_name_suffix        = string
    vm_size               = string
    rg_key                = string
    subnet_key            = string
    priority              = optional(string, "Regular")
    eviction_policy       = optional(string)
    max_bid_price         = optional(number)
    public_ip_enabled     = optional(bool, false)
    authentication_method = optional(string, "password")
    nsg_rules = map(object({
      name                   = string
      priority               = number
      direction              = string
      access                 = string
      protocol               = string
      destination_port_range = optional(string)
    }))
  }))

}

variable "key_vault_details" {
  description = "Details for the Key Vault"
  type = object({
    key_vault_name      = string
    resource_group_name = string
    secrets = object({
      vm_username = string
      vm_password = string
    })
  })
}

variable "private_dns_zone" {
  type = map(object({
    name_suffix       = string
    rg_key            = string
    vnet_link_enabled = optional(bool, false)
    vnet_key          = optional(string, null)
  }))
}


variable "postgresql_flexible_server" {
  type = map(object({
    name_suffix                   = string
    rg_key                        = string
    version                       = string
    subnet_key                    = string
    private_dns_zone_key          = string
    public_network_access_enabled = optional(bool, false)
    login_thru_this_pc            = optional(string, "yes")
  }))
}

variable "webapp_config" {
  type = map(object({
    asp_name              = string
    os_type               = string
    sku_name              = string
    name                  = string
    rg_key                = string
    app_type              = string
    runtime_version       = string
    public_network_access = optional(bool, true)
    delegated_subnet_key  = optional(string, null)
    startup_command       = optional(string, "")
  }))
}

variable "database_name" {
  type        = string
  description = "Name of the PostgreSQL application database"
}
