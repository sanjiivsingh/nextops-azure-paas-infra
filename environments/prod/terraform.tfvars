project = "nextops"
environment = "dev"
location = "centralindia"

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
  "frontend-subnet" = {
    name_suffix      = "fe01"
    rg_key           = "rg1"
    vnet_key         = "spokevnet1"
    dedicated_subnet = false
    subnet_num       = 01
    subnet_prefix    = 24
  }
  "backend-subnet" = {
    name_suffix      = "be01"
    rg_key           = "rg1"
    vnet_key         = "spokevnet1"
    dedicated_subnet = false
    subnet_num       = 02
    subnet_prefix    = 24
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
    subnet_key        = "frontend-subnet"
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
      "http" = {
        name                   = "http"
        priority               = 310
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "*"
        destination_port_range = "80"
      }
    }
  }

  "linux_vm_02" = {
    vm_os             = "Linux"
    vm_name_suffix    = "lin02"
    vm_size           = "Standard_D2s_v5"
    rg_key            = "rg1"
    subnet_key        = "backend-subnet"
    public_ip_enabled = false
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
      "backend" = {
        name                   = "backend"
        priority               = 310
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        destination_port_range = "8000"
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
    login_thru_this_pc            = "No"
  }
}
