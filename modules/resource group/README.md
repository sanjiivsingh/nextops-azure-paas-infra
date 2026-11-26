# Azure Resource Group Child Module

## Overview

Provisions one or more **Azure Resource Groups** (`azurerm_resource_group`) from a `map(object(...))` configuration.

## File Structure

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| `resource-group.tf` | Creates Resource Groups via `for_each` | `azurerm_resource_group.this` |
| `variable.tf` | Declares `resource_group_config` | N/A |
| `output.tf` | Exposes `resource_group_output` map (`name`, `location`) | N/A |
| `version.tf` | Provider/version constraints | N/A |

## Inputs

| Name | Description | Type |
| :--- | :--- | :--- |
| `resource_group_config` | Map of resource group objects (`name`, `location`, optional `tags`) | `map(object({...}))` |

## Outputs

| Name | Description |
| :--- | :--- |
| `resource_group_output` | Map keyed by input key returning `{ name, location }` |
