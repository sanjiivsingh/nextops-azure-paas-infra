output "postgreSQL_fqdn" {
  value = {
    for k, v in var.postgresql_flexible_server :
    k => {
      psql_endpoint = module.postgresql_flexible_server[k].psql_output.fqdn
    }
  }
}
output "vm_public_ip" {
  value = {
    for key, value in var.virtual_machines_config : key => {
      vm_public_ip_address = value.public_ip_enabled == true ? module.virtual_machines[key].vm_public_ip_output[0].ip_address : null
    }
  }
}