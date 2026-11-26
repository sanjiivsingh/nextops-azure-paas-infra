# `dev` Environment

Active **NextOps Industrial** PaaS landing zone environment deployed to **Central India** (`rg-nextops-dev-01`).

## Resource Inventory

| Component | Terraform Name / Resource | Azure Name | Details |
| :--- | :--- | :--- | :--- |
| **Resource Group** | `module.resource_group` | `rg-nextops-dev-01` | Region: `centralindia` |
| **Hub VNet** | `hubvnet` | `vnet-nextops-dev-hub01` | `10.125.0.0/16`, peered with spoke |
| **Spoke VNet** | `spokevnet1` | `vnet-nextops-dev-spk01` | `10.126.0.0/16`, peered with hub |
| **Frontend Subnet** | `frontend-subnet` | `subnet-nextops-dev-fe01` | `10.126.1.0/24` |
| **Backend Subnet** | `backend-subnet` | `subnet-nextops-dev-be01` | `10.126.2.0/24`, delegated to `Microsoft.Web/serverFarms` |
| **Database Subnet** | `database-subnet` | `subnet-nextops-dev-pg01` | `10.126.3.0/24`, delegated to `Microsoft.DBforPostgreSQL/flexibleServers` |
| **VM Subnet** | `vm-subnet` | `subnet-nextops-dev-vm01` | `10.126.4.0/24` |
| **Jumpbox VM** | `linux_vm_01` | `vm-nextops-lin01` | `Standard_D2s_v5`, Ubuntu 22.04 LTS, Public IP, NSG SSH `:22` |
| **Private DNS Zone** | `pvt_dns_zone_1` | `nextops-psqlflexibleserver.postgres.database.azure.com` | Linked to `vnet-nextops-dev-spk01` |
| **PostgreSQL Server** | `psql-server` | `nextops-dev-psql-db` | PostgreSQL 16, `GP_Standard_D2s_v3`, 32 GB `P4`, private access only |
| **Frontend Web App** | `frontend-webapp` | `nextops-dashboard` | ASP `asp-linux-webapp-frontend` (`B1`), Node `24-lts`, `pm2` SPA |
| **Backend Web App** | `backend_webapp` | `nextops-be` | ASP `asp-linux-webapp-backend` (`B1`), Python `3.12`, `uvicorn`, VNet-integrated |

## Usage

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Outputs

- `postgreSQL_fqdn`: FQDN of `nextops-dev-psql-db`
- `vm_public_ip`: Public IP address of `vm-nextops-lin01`
- `webapp`: Default HTTPS hostnames for `nextops-dashboard` and `nextops-be`
- `resource_group_output`: Provisioned resource group name (`rg-nextops-dev-01`)

> **State Management:** `backend.tf` intentionally leaves the `azurerm` remote backend commented out; state is kept locally and excluded via `.gitignore`.
