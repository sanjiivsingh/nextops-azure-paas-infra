# Azure Linux Web App Terraform Child Module (`webapp`)

## Overview

The `webapp` module provisions an **Azure App Service Plan (Linux)** (`azurerm_service_plan`) and a **Linux Web App** (`azurerm_linux_web_app`) supporting Node.js and Python workloads with optional regional VNet integration and stack-aware `app_settings`.

## File Structure

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| `main.tf` | Creates the App Service Plan and Linux Web App with `https_only`, `always_on`, VNet integration, `application_stack`, and `app_command_line` | `azurerm_service_plan.asp`, `azurerm_linux_web_app.webapp` |
| `local.tf` | Defines stack-specific default `app_settings` (`node`, `python`) and merges custom `app_settings` | N/A |
| `variable.tf` | Declares the `webapp_config` input object schema | N/A |
| `output.tf` | Exposes the Web App's HTTPS `default_hostname` | N/A |

## Inputs

| Name | Description | Type | Required |
| :--- | :--- | :--- | :---: |
| `webapp_config` | Configuration object for the App Service Plan and Linux Web App | `object({...})` | Yes |

### `webapp_config` Attributes

| Attribute | Type | Default | Description |
| :--- | :--- | :---: | :--- |
| `asp_name` | `string` | — | Name of the Linux App Service Plan |
| `os_type` | `string` | — | OS type for the plan (`"Linux"`) |
| `sku_name` | `string` | — | App Service Plan SKU (e.g., `"B1"`) |
| `name` | `string` | — | Globally unique Linux Web App name |
| `resource_group_name` | `string` | — | Target resource group name |
| `location` | `string` | — | Azure region |
| `app_type` | `string` | — | `"node"` or `"python"` |
| `runtime_version` | `string` | — | Stack version (e.g., `"24-lts"` for Node, `"3.12"` for Python) |
| `public_network_access` | `bool` | `true` | Enables or disables public inbound access |
| `startup_command` | `string` | `""` | Custom `app_command_line` (e.g., `pm2 serve ...` or `python -m uvicorn ...`) |
| `virtual_network_subnet_id` | `string` | `null` | Delegated subnet ID for regional VNet integration; sets `vnet_route_all_enabled = true` when non-null |
| `app_settings` | `map(string)` | `{}` | Custom environment variables merged over stack defaults |

### Default `app_settings` by `app_type`

- **`node`**: `SCM_DO_BUILD_DURING_DEPLOYMENT = "false"`
- **`python`**: `SCM_DO_BUILD_DURING_DEPLOYMENT = "true"`, `ENVIRONMENT = "development"`, `PORT = "8000"`

## Outputs

| Name | Description |
| :--- | :--- |
| `webapp_url` | Full HTTPS URL (`https://<default_hostname>`) of the provisioned Web App |
