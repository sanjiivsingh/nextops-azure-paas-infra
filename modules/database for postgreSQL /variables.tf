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
    login_thru_this_pc            = optional(string, "yes")
    start_ip_address              = optional(string)
    end_ip_address                = optional(string)
  })
}
