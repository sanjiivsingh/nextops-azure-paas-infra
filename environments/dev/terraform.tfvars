project       = "nextops"
environment   = "dev"
location      = "centralindia"
database_name = "nextops"

tags = {
  owner     = "infra team"
  managedBy = "Terraform"
}

resource_groups = {
  "rg1" = {
    name_suffix = "01"
  }
}

virtual_network_config = {
  "hubvnet" = {
    name_suffix   = "hub01"
    rg_key        = "rg1"
    address_space = ["10.125.0.0/16"]
  }
  "spokevnet1" = {
    name_suffix     = "spk01"
    rg_key          = "rg1"
    address_space   = ["10.126.0.0/16"]
    peering_enabled = true
    remote_vnet_key = "hubvnet"
  }
}

subnet_config = {
  "vm-subnet" = {
    name_suffix      = "vm01"
    rg_key           = "rg1"
    vnet_key         = "spokevnet1"
    dedicated_subnet = false
    subnet_num       = 04
    subnet_prefix    = 24
  }
  "frontend-subnet" = {
    name_suffix        = "fe01"
    rg_key             = "rg1"
    vnet_key           = "spokevnet1"
    dedicated_subnet   = false
    subnet_num         = 01
    subnet_prefix      = 24
    delegation_enabled = false
    delegation_service = "Microsoft.Web/serverFarms"
  }
  "backend-subnet" = {
    name_suffix        = "be01"
    rg_key             = "rg1"
    vnet_key           = "spokevnet1"
    dedicated_subnet   = false
    subnet_num         = 02
    subnet_prefix      = 24
    delegation_enabled = true
    delegation_service = "Microsoft.Web/serverFarms"
  }

  "database-subnet" = {
    name_suffix        = "pg01"
    rg_key             = "rg1"
    vnet_key           = "spokevnet1"
    dedicated_subnet   = false
    subnet_num         = 03
    subnet_prefix      = 24
    delegation_enabled = true
    delegation_service = "Microsoft.DBforPostgreSQL/flexibleServers"
  }

}


# Virtual Machine Configuration
virtual_machines_config = {
  "linux_vm_01" = {
    vm_os             = "Linux"
    vm_name_suffix    = "lin01"
    vm_size           = "Standard_D2s_v5"
    rg_key            = "rg1"
    subnet_key        = "vm-subnet"
    public_ip_enabled = true
    # Choose authentication method between "password" and "ssh_key" for a linux vm
    authentication_method = "password"
    nsg_rules = {
      "ssh" = {
        name                   = "SSH"
        priority               = 300
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        destination_port_range = "22"
      }
    }
  }
}

key_vault_details = {
  key_vault_name      = "onepskv"
  resource_group_name = "rg-oneps-keyvault"
  secrets = {
    "vm_username" = "vm-username"
    "vm_password" = "vm-password"
  }
}

private_dns_zone = {
  "pvt_dns_zone_1" = {
    name_suffix       = "psqlflexibleserver"
    rg_key            = "rg1"
    vnet_link_enabled = true
    vnet_key          = "spokevnet1"
  }
}

postgresql_flexible_server = {
  "psql-server" = {
    name_suffix                   = "psql-db"
    rg_key                        = "rg1"
    version                       = "16"
    subnet_key                    = "database-subnet"
    private_dns_zone_key          = "pvt_dns_zone_1"
    public_network_access_enabled = false
    login_thru_this_pc            = "no"
  }
}
webapp_config = {
  frontend-webapp = {
    asp_name              = "asp-linux-webapp-frontend"
    os_type               = "Linux"
    sku_name              = "B1"
    name                  = "nextops-dashboard"
    public_network_access = true
    rg_key                = "rg1"
    app_type              = "node"
    runtime_version       = "24-lts"
    startup_command       = "pm2 serve /home/site/wwwroot --no-daemon --spa"
  }
  backend_webapp = {
    asp_name              = "asp-linux-webapp-backend"
    os_type               = "linux"
    sku_name              = "B1"
    name                  = "nextops-be"
    public_network_access = true
    delegated_subnet_key  = "backend-subnet"
    rg_key                = "rg1"
    app_type              = "python"
    runtime_version       = "3.12"
    startup_command       = "python -m uvicorn main:app --host 0.0.0.0 --port 8000"
  }
}
