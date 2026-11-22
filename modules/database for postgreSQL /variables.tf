variable "postgresql_flexible_server_config" {
  type = object({
    name                          = string
    resource_group_name           = string
    location                      = string
    version                       = string
    delegated_subnet_id           = string
    private_dns_zone_id           = string
    public_network_access_enabled = optional(bool, false)
    administrator_login           = string
    administrator_password        = string
    start_ip_address              = optional(string)
    end_ip_address                = optional(string)
  })
}
