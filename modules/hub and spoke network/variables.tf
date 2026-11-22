
variable "virtual_network_config" {
  description = "Virtual network configurations"

  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    tags                = map(string)
  }))
}

variable "subnet_config" {
  description = "Subnet configurations"

  type = map(object({
    name                = string
    resource_group_name = string
    vnet_key            = string
    address_prefixes    = list(string)
    delegation_enabled  = optional(bool, false)
    delegation_service  = optional(string, null)
  }))
}

variable "vnet_peering_config" {
  type = map(object({
    name                = string
    resource_group_name = string
    source_vnet_key     = string
    remote_vnet_key     = string
  }))
}
