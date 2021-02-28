# Terraform
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "2.47.0"
        }
    }

    backend "azurerm" {
        resource_group_name  = "terraformstate-rg"
        storage_account_name = "thomcstoneterrastate"
        container_name       = "terrastate"
        key                  = "test.terraform.tfstate"
    }
}

#Azure provider
provider "azurerm" {
    features {}
}

variable "prefix" {
    default = "terraform-winvm"
}

# Name of existing resource group where Key Vault resides goes here
variable "existing-rg" {
    default = "thomcstone-kv"
}

# Existing location for resource group above goes here
variable "existing-rg-location" {
    default ="West US 2"
}

# Name of existing Key Vault goes here
variable "existing-kv-name" {
    default = "thomcstone-kv"
}

# New resource group for new resources
resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-rg"
    location = "West US 2"
}

# New VNET
resource "azurerm_virtual_network" "vnet" {
    name = "${var.prefix}-vnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# New Subnet
resource "azurerm_subnet" "internal" {
    name = "internal"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}

# New Public IP, so we can RDP to verify fetching our Key Vault secrets worked
resource "azurerm_public_ip" "publicip" {
    name = "${var.prefix}-ip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Dynamic"
}

# New NIC with Public IP
resource "azurerm_network_interface" "nic0" {
    name = "${var.prefix}-nic0"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "nic0"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.internal.id
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
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

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

# New VM
resource "azurerm_windows_virtual_machine" "winvm" {
    name = var.prefix
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [ azurerm_network_interface.nic0.id ]
    size = "Standard_B1s"
    admin_username = data.azurerm_key_vault_secret.kvsecret1.value
    admin_password = data.azurerm_key_vault_secret.kvsecret2.value
    
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }
}

# Existing Resource Group where existing Key Vault resides
resource "azurerm_resource_group" "rg1" {
    name = var.existing-rg
    location = var.existing-rg-location
}

# Initialized to grab tenant ID for Key Vault
data "azurerm_client_config" "current" {}

# Existing Key Vault
resource "azurerm_key_vault" "kv" {
    name = var.existing-kv-name
    location = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name
    tenant_id = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
}

# Initialized so in following steps Key Vault secrets can be referenced
data "azurerm_key_vault" "kvdata" {
    name = var.existing-kv-name
    resource_group_name = azurerm_resource_group.rg1.name
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
