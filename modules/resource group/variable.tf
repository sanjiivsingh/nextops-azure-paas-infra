variable "resource_group_config" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(any), {})
  }))
  description = "Resource group configuration"
}