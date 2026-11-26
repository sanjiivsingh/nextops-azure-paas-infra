variable "webapp_config" {
  type = object({
    asp_name                  = string
    os_type                   = string
    sku_name                  = string
    name                      = string
    resource_group_name       = string
    location                  = string
    app_type                  = string
    runtime_version           = string
    public_network_access     = optional(bool, true)
    startup_command           = optional(string, "")
    virtual_network_subnet_id = optional(string, null)
    app_settings              = optional(map(string), {})
  })
}

