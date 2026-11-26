# Azure Private DNS Zone Child Module

## Overview

Provisions an **Azure Private DNS Zone** (`azurerm_private_dns_zone`) and conditionally links it to a target Virtual Network (`azurerm_private_dns_zone_virtual_network_link`).

## File Structure

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| `main.tf` | Creates the Private DNS Zone and optional VNet link | `azurerm_private_dns_zone.this`, `azurerm_private_dns_zone_virtual_network_link.this` |
| `variable.tf` | Declares `private_dns_zone_config` | N/A |
| `output.tf` | Exposes `private_dns_zone_output` | N/A |

## Inputs

| Name | Description | Type |
| :--- | :--- | :--- |
| `private_dns_zone_config` | Configuration object (`name`, `resource_group_name`, `vnet_link_name`, `virtual_network_id`, `vnet_link_enabled`) | `object({...})` |

## Outputs

| Name | Description |
| :--- | :--- |
| `private_dns_zone_output` | Full `azurerm_private_dns_zone` resource object (including `.id` and `.name`) |
