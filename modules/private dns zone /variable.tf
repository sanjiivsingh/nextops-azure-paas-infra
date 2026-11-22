variable "private_dns_zone_config" {
  type = object({
    name                = string
    resource_group_name = string
    vnet_link_name      = string
    virtual_network_id  = string
    vnet_link_enabled = optional(bool, false)
    
  })
}
