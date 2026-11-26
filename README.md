# NextOps Azure PaaS Landing Zone (`infra-nextops`)

Enterprise-grade Terraform Infrastructure-as-Code (IaC) and operational deployment automation for the **NextOps Industrial** telemetry and digital-twin platform on Microsoft Azure.

This landing zone provisions a modular, security-hardened **hub-and-spoke Azure PaaS architecture** hosting a React/Node.js SPA dashboard (`nextops-dashboard`), a VNet-integrated Python FastAPI backend (`nextops-be`), a private Azure Database for PostgreSQL Flexible Server (`nextops-dev-psql-db` / `nextops-prod-psql-db`), Private DNS integration, and an Ubuntu Linux bastion/jumpbox VM.

---

## Architecture Overview

![NextOps Azure PaaS Landing Zone](./docs/nextops-landing-zone-paas.png)

### Network & Traffic Flow

```mermaid
flowchart LR
  User["User / Browser"] -->|HTTPS| FE["App Service: Frontend<br/>Node 24-LTS (B1)"]
  FE -->|"HTTPS (API_BASE_URL)"| BE["App Service: Backend<br/>Python 3.12 (B1)"]
  BE -->|"VNet Integration<br/>(vnet_route_all_enabled)"| S_BE["Spoke Subnet: backend<br/>10.126.2.0/24"]
  S_BE -->|"Private DNS + Port 5432<br/>(DATABASE_URL)"| DB["PostgreSQL Flexible Server v16<br/>10.126.3.0/24 (Delegated)"]
  Admin["Operator (SSH :22)"] -->|Public IP| VM["Jumpbox VM: vm-nextops-lin01<br/>10.126.4.0/24"]
  VM -->|"psql (SSL required)"| DB
  HUB["Hub VNet<br/>10.125.0.0/16"] <-->|"Bidirectional VNet Peering"| SPK["Spoke VNet<br/>10.126.0.0/16"]
  KV["External Key Vault: onepskv<br/>(rg-oneps-keyvault)"] -.->|"Plan/Apply Secrets"| TF["Terraform"]
```

---

## Key Design Decisions & Security Controls

- **Hub-and-Spoke Network Segmentation**: Separates shared connectivity (`vnet-nextops-<env>-hub01`, `10.125.0.0/16`) from workload subnets (`vnet-nextops-<env>-spk01`, `10.126.0.0/16`) with bidirectional VNet peering and dedicated `/24` subnets for frontend, backend, database, and management tiers.
- **Zero Public Exposure for Data Tier**: PostgreSQL Flexible Server (`v16`) is deployed with `public_network_access_enabled = false`, delegated to `subnet-nextops-<env>-pg01`, and resolved internally via an Azure Private DNS Zone (`nextops-psqlflexibleserver.postgres.database.azure.com`).
- **VNet-Integrated Backend Routing**: The FastAPI App Service (`nextops-be`) integrates with `subnet-nextops-<env>-be01` (`Microsoft.Web/serverFarms` delegation) with `vnet_route_all_enabled = true`, ensuring all database queries traverse private VNet space over TLS.
- **Zero-Secret Repository**: All VM and database credentials are fetched dynamically at plan/apply time from an external Azure Key Vault (`onepskv` in `rg-oneps-keyvault`), and `.gitignore` excludes all `*.tfstate` and `.terraform/` artifacts.
- **Environment Parity (`dev` & `prod`)**: Both `dev` and `prod` environments share an identical modular PaaS topology, naming convention, and CIDR layout, with `prod` dynamically deriving `API_BASE_URL` from its configured backend Web App.

---

## Repository Structure

```text
infra-nextops/
├── .gitignore                          # Excludes *.tfstate, .terraform/, crash logs, and OS files
├── docs/
│   └── nextops-landing-zone-paas.png   # Reference PaaS landing zone architecture diagram
├── environments/
│   ├── dev/                            # Dev environment (centralindia, rg-nextops-dev-01)
│   │   ├── README.md
│   │   ├── backend.tf                  # Remote azurerm backend template (local state active)
│   │   ├── data.tf                     # Key Vault secret lookups & caller IP data source
│   │   ├── local.tf                    # Naming, CIDR calculation, Web App app_settings assembly
│   │   ├── main.tf                     # Root module orchestration
│   │   ├── outputs.tf                  # DB FQDN, jumpbox IP, Web App URLs, RG names
│   │   ├── provider.tf                 # hashicorp/azurerm ~> 5.0 & hashicorp/http
│   │   ├── terraform.tfvars            # Dev environment configuration
│   │   └── variables.tf
│   └── prod/                           # Production environment (full parity with dev PaaS topology)
│       ├── README.md
│       └── ...
├── modules/
│   ├── resource group/                 # Azure Resource Group provisioning
│   ├── hub and spoke network/          # VNets, CIDR-derived subnets, delegations, bidirectional peering
│   ├── virtual machine/                # Multi-OS VM (Ubuntu/Windows), NIC, NSG, optional Public IP
│   ├── private dns zone /              # Private DNS zone + VNet link for PostgreSQL
│   ├── database for postgreSQL /       # Private PostgreSQL Flexible Server v16 + conditional firewall rules
│   └── webapp/                         # Linux App Service Plan + Linux Web App (Node / Python)
├── nextops-db-init.sh                  # Initializes PostgreSQL schema & seeds telemetry data
├── nextops-deploy-backend.sh           # Deploys nextops-backend.zip to App Service (nextops-be)
├── nextops-deploy-frontend.sh          # Deploys nextops-dashboard-build.zip to App Service (nextops-dashboard)
├── nextops-backend.zip                 # Prebuilt FastAPI backend package
└── nextops-dashboard-build.zip         # Prebuilt React/Vite SPA dist package
```

---

## Web App (App Service) Configuration

Both frontend and backend run on **Azure App Service for Linux** via [`modules/webapp`](./modules/webapp/README.md). Every Web App enforces `https_only = true` and `always_on = true`.

### Configured Workloads (`dev` & `prod`)

| Property | Frontend (`frontend-webapp`) | Backend (`backend_webapp`) |
| :--- | :--- | :--- |
| **App Service Name (`dev` / `prod`)** | `nextops-dashboard` / `nextops-dashboard-prod` | `nextops-be` / `nextops-be-prod` |
| **App Service Plan (`dev` / `prod`)** | `asp-linux-webapp-frontend` / `...-prod` | `asp-linux-webapp-backend` / `...-prod` |
| **OS / SKU** | `Linux` / `B1` | `Linux` / `B1` |
| **App Type & Runtime** | `node` (`24-lts`) | `python` (`3.12`) |
| **Public Network Access** | `true` | `true` |
| **VNet Integration (`delegated_subnet_key`)** | `null` (public ingress) | `backend-subnet` (`subnet-nextops-<env>-be01`, `vnet_route_all_enabled = true`) |
| **Startup Command (`app_command_line`)** | `pm2 serve /home/site/wwwroot --no-daemon --spa` | `python -m uvicorn main:app --host 0.0.0.0 --port 8000` |

### Environment Variables (`app_settings`)

[`modules/webapp/local.tf`](./modules/webapp/local.tf) merges **stack defaults** with **environment-specific overrides** from `environments/<env>/local.tf`:

| Stack / Tier | Variable | Value / Source | Purpose |
| :--- | :--- | :--- | :--- |
| **Node (default)** | `SCM_DO_BUILD_DURING_DEPLOYMENT` | `"false"` | Serves prebuilt SPA bundle (`nextops-dashboard-build.zip`) directly without Oryx rebuild |
| **Node (env)** | `API_BASE_URL` | `https://<backend-webapp>.azurewebsites.net` | Target backend API base URL for the dashboard |
| **Node (env)** | `ENVIRONMENT` | `var.environment` (`dev` / `prod`) | Runtime environment identifier |
| **Python (default)** | `SCM_DO_BUILD_DURING_DEPLOYMENT` | `"true"` | Triggers Oryx `pip install` on zip deployment for `nextops-backend.zip` |
| **Python (default)** | `PORT` | `"8000"` | Aligns App Service container port with Uvicorn `--port 8000` |
| **Python (env)** | `ENVIRONMENT` | `var.environment` (`dev` / `prod`) | Overrides default `"development"` with active environment |
| **Python (env)** | `DATABASE_URL` | `postgresql://<db_user>:<urlencoded_db_password>@<psql_fqdn>:5432/<database_name>` | Private PostgreSQL connection string resolved via Private DNS over VNet integration |

> `DATABASE_URL` URL-encodes the database password (`urlencode(...)`) in `local.tf` so special characters in Key Vault secrets do not break PostgreSQL URI parsing.

---

## Prerequisites & External Dependencies

1. **CLI Tools**:
   - Terraform (`>= 1.5`, provider `hashicorp/azurerm ~> 5.0`)
   - Azure CLI (`az`), authenticated via `az login` with access to the target subscription
   - `psql` (`libpq`) on the jumpbox VM for database initialization
2. **Pre-Existing Azure Key Vault**:
   Terraform reads secrets at plan/apply time from the Key Vault defined in `key_vault_details`:
   - **Key Vault**: `onepskv` in resource group `rg-oneps-keyvault`
   - **Required Secrets**:
     - `vm-username` — Jumpbox Linux VM admin username
     - `vm-password` — Jumpbox Linux VM admin password (when `authentication_method = "password"`)
     - `linux-vm-ssh-public-key` — Jumpbox SSH public key (when `authentication_method = "ssh_key"`)
     - `db-username` — PostgreSQL Flexible Server administrator username
     - `db-password` — PostgreSQL Flexible Server administrator password

---

## Provisioning & Deployment Runbook

### 1. Provision Infrastructure

```bash
cd environments/dev   # or environments/prod
terraform init
terraform plan
terraform apply
```

Capture the outputs (`postgreSQL_fqdn`, `vm_public_ip`, `webapp`, `resource_group_output`).

### 2. Initialize PostgreSQL Schema & Seed Data

Because PostgreSQL is isolated inside the spoke VNet (`public_network_access_enabled = false`), run `nextops-db-init.sh` from the jumpbox VM (`vm-nextops-lin01`) over SSH:

```bash
# Copy script to jumpbox
scp nextops-db-init.sh <vm_username>@<vm_public_ip>:~

# SSH into jumpbox and execute
ssh <vm_username>@<vm_public_ip>
chmod +x nextops-db-init.sh
./nextops-db-init.sh
```

The script prompts for the PostgreSQL admin credentials and database name (default: `nextops`), creates the database if missing, creates `public.telemetry` with index `idx_telemetry_device_timestamp`, and seeds 144 sample telemetry rows (12 devices × 12 hours).

### 3. Deploy Application Packages

From the `infra-nextops/` root directory (authenticated with `az login`):

```bash
# Deploy Python FastAPI backend to nextops-be
./nextops-deploy-backend.sh

# Deploy prebuilt React SPA frontend to nextops-dashboard
./nextops-deploy-frontend.sh
```

Both scripts use `az webapp deploy --type zip` against the production slot while preserving Terraform-managed `app_settings`, runtime versions, and startup commands.

---

## Author & Architecture Credit

- **Infrastructure Design & Landing Zone Architecture**: **Sanjeev Singh** ([GitHub](https://github.com/sanjiivsingh))
- **Scope**: End-to-end Azure PaaS landing zone architecture, hub-and-spoke network topology, reusable Terraform child modules, private PostgreSQL + Private DNS integration, App Service runtime/VNet configuration, and deployment automation.
