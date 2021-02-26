# Terraform
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "2.47.0"
        }
    }
}

#Azure provider
provider "azurerm" {
    features {}
}

variable "prefix" {
    default = "terraform-winvm"
}

variable "existing-rg" {
    default = "thomcstone-kv"
}

variable "existing-rg-location" {
    default ="West US 2"
}

variable "existing-kv-name" {
    default = "thomcstone-kv"
}

resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-rg"
    location = "West US 2"
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.prefix}-vnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
    name = "internal"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic0" {
    name = "${var.prefix}-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "nic0"
        subnet_id = azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "winvm" {
    name = "${var.prefix}-vm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [ azurerm_network_interface.nic0.id ]
    size = "Standard_B1s"
    admin_username = "${data.azurerm_key_vault_secret.kvsecret1.value}"
    admin_password = "value"
    
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

resource "azurerm_resource_group" "rg1" {
    name = var.existing-rg
    location = var.existing-rg-location
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
    name = var.existing-kv-name
    location = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name
    tenant_id = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
}

data "azurerm_key_vault" "kvdata" {
    name = var.existing-kv-name
    resource_group_name = azurerm_resource_group.rg1.name
}

data "azurerm_key_vault_secret" "kvsecret1" {
    name = "WinVMUser"
    key_vault_id = data.azurerm_key_vault.kvdata.id
}