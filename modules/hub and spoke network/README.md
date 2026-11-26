# Azure Hub-and-Spoke Network Terraform Child Module

## Overview

Provisions Azure Virtual Networks, CIDR-calculated Subnets (with optional service delegations), and bidirectional VNet Peerings.

## File Structure

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| `virtual-network.tf` | Creates Hub and Spoke Virtual Networks | `azurerm_virtual_network.this` |
| `subnets.tf` | Creates Subnets with optional `service_delegation` blocks | `azurerm_subnet.this` |
| `vnet-peering.tf` | Creates bidirectional VNet Peerings with forwarded traffic enabled | `azurerm_virtual_network_peering.this` |
| `variables.tf` | Declares `virtual_network_config`, `subnet_config`, `vnet_peering_config` | N/A |
| `outputs.tf` | Exposes `virtual_network_output` and `subnet_output` maps | N/A |

## Inputs

| Name | Type | Description |
| :--- | :--- | :--- |
| `virtual_network_config` | `map(object({...}))` | Map of VNets (`name`, `location`, `resource_group_name`, `address_space`, `tags`) |
| `subnet_config` | `map(object({...}))` | Map of Subnets (`name`, `resource_group_name`, `vnet_key`, `address_prefixes`, `delegation_enabled`, `delegation_service`) |
| `vnet_peering_config` | `map(object({...}))` | Map of Peerings (`name`, `resource_group_name`, `source_vnet_key`, `remote_vnet_key`) |

## Outputs

| Name | Description |
| :--- | :--- |
| `virtual_network_output` | Map of `azurerm_virtual_network` objects keyed by VNet key |
| `subnet_output` | Map of `azurerm_subnet` objects keyed by subnet key |
