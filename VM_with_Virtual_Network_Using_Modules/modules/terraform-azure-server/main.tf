# Terraform
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "2.47.0"
        }
    }
}

# New Public IP, so we can RDP to verify fetching our Key Vault secrets worked
resource "azurerm_public_ip" "publicip" {
    name = "${var.prefix}-ip"
    resource_group_name = var.resource_group_name
    location = var.location
    allocation_method = "Dynamic"
}

# New NIC with Public IP
resource "azurerm_network_interface" "nic0" {
    name = "${var.prefix}-nic0"
    location = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name = "nic0"
        private_ip_address_allocation = "Dynamic"
        subnet_id = var.subnet_id
        public_ip_address_id = azurerm_public_ip.publicip.id
    }
}

# Get local Source IP address to use for security rule
data "external" "myipaddr" {
program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

# Network Security Group that allows RDP
resource "azurerm_network_security_group" "nsg" {
    name = "Allow-RDP-Inbound"
    location = var.location
    resource_group_name = var.resource_group_name

    security_rule {
    name = "Allow-RDP-Inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = data.external.myipaddr.result.ip
    destination_address_prefix = "*"
    }
}

# Attach the Network Security Group to NIC0 on the new VM
resource "azurerm_network_interface_security_group_association" "nsg-nic" {
    network_interface_id = azurerm_network_interface.nic0.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "winvm" {
    name = var.prefix
    location = var.location
    resource_group_name = var.resource_group_name
    network_interface_ids = [ azurerm_network_interface.nic0.id ]
    size = var.size
    admin_username = data.azurerm_key_vault_secret.kvsecret1.value
    admin_password = data.azurerm_key_vault_secret.kvsecret2.value
    
    os_disk {
        caching = "ReadWrite"
        storage_account_type = lookup(var.storage_account_type, var.location)
    }

    source_image_reference {
        publisher = var.os.publisher
        offer = var.os.offer
        sku = var.os.sku
        version = var.os.version
    }
}

# Initialized so in following steps Key Vault secrets can be referenced
data "azurerm_key_vault" "kvdata" {
    name = var.existing-kv-name
    resource_group_name = var.existing-rg
}

# Existing secret in Key Vault for user name
data "azurerm_key_vault_secret" "kvsecret1" {
    name = "WinVMUser"
    key_vault_id = data.azurerm_key_vault.kvdata.id
}

# Existing secret in Key Vault for password
data "azurerm_key_vault_secret" "kvsecret2" {
    name = "WinVMPassword"
    key_vault_id = data.azurerm_key_vault.kvdata.id
}