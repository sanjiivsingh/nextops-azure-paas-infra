# `prod` Environment

Production **NextOps Industrial** PaaS landing zone environment deployed to **Central India** (`rg-nextops-prod-01`), configured with full structural parity to `environments/dev`.

## Resource Inventory

| Component | Terraform Name / Resource | Azure Name | Details |
| :--- | :--- | :--- | :--- |
| **Resource Group** | `module.resource_group` | `rg-nextops-prod-01` | Region: `centralindia` |
| **Hub VNet** | `hubvnet` | `vnet-nextops-prod-hub01` | `10.125.0.0/16`, peered with spoke |
| **Spoke VNet** | `spokevnet1` | `vnet-nextops-prod-spk01` | `10.126.0.0/16`, peered with hub |
| **Frontend Subnet** | `frontend-subnet` | `subnet-nextops-prod-fe01` | `10.126.1.0/24` |
| **Backend Subnet** | `backend-subnet` | `subnet-nextops-prod-be01` | `10.126.2.0/24`, delegated to `Microsoft.Web/serverFarms` |
| **Database Subnet** | `database-subnet` | `subnet-nextops-prod-pg01` | `10.126.3.0/24`, delegated to `Microsoft.DBforPostgreSQL/flexibleServers` |
| **VM Subnet** | `vm-subnet` | `subnet-nextops-prod-vm01` | `10.126.4.0/24` |
| **Jumpbox VM** | `linux_vm_01` | `vm-nextops-lin01` | `Standard_D2s_v5`, Ubuntu 22.04 LTS, Public IP, NSG SSH `:22` |
| **Private DNS Zone** | `pvt_dns_zone_1` | `nextops-psqlflexibleserver.postgres.database.azure.com` | Linked to `vnet-nextops-prod-spk01` |
| **PostgreSQL Server** | `psql-server` | `nextops-prod-psql-db` | PostgreSQL 16, `GP_Standard_D2s_v3`, 32 GB `P4`, private access only |
| **Frontend Web App** | `frontend-webapp` | `nextops-dashboard-prod` | ASP `asp-linux-webapp-frontend-prod` (`B1`), Node `24-lts`, `pm2` SPA |
| **Backend Web App** | `backend_webapp` | `nextops-be-prod` | ASP `asp-linux-webapp-backend-prod` (`B1`), Python `3.12`, `uvicorn`, VNet-integrated |

## Usage

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

> **Note:** In `prod`, `API_BASE_URL` on `nextops-dashboard-prod` is dynamically derived from `var.webapp_config["backend_webapp"].name` (`https://nextops-be-prod.azurewebsites.net`).
