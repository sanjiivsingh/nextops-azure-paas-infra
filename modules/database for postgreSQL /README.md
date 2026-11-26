# Azure Database for PostgreSQL Flexible Server Child Module

## Overview

Provisions an **Azure Database for PostgreSQL Flexible Server** (`azurerm_postgresql_flexible_server`) with private VNet delegation, Private DNS integration, and optional conditional firewall rules when public access is enabled.

## File Structure

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| `main.tf` | Provisions PostgreSQL Flexible Server (`GP_Standard_D2s_v3`, 32 GB `P4`, zone `1`) and conditional firewall rules | `azurerm_postgresql_flexible_server.this`, `azurerm_postgresql_flexible_server_firewall_rule.this` |
| `variables.tf` | Declares `postgresql_flexible_server_config` | N/A |
| `output.tf` | Exposes `psql_output` | N/A |

## Inputs

| Name | Description | Type |
| :--- | :--- | :--- |
| `postgresql_flexible_server_config` | Configuration object (`name`, `resource_group_name`, `location`, `version`, `delegated_subnet_id`, `private_dns_zone_id`, `public_network_access_enabled`, `administrator_login`, `administrator_password`, `login_thru_this_pc`, `start_ip_address`, `end_ip_address`) | `object({...})` |

## Outputs

| Name | Description |
| :--- | :--- |
| `psql_output` | Full `azurerm_postgresql_flexible_server` resource object (including `.fqdn` and `.id`) |
