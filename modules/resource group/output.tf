output "resource_group_output" {
  value = {
    for key, value in azurerm_resource_group.this :
    key => {
      name     = value.name
      location = value.location
    }
  }
}
