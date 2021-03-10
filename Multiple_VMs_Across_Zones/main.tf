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
        key                  = "test5.terraform.tfstate"
    }
}

provider "azurerm" {
    features {}
}

# New resource group for new resources
resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-rg"
    location = var.location
}

# New VNET
resource "azurerm_virtual_network" "vnet" {
    name = "${var.prefix}-vnet"
    address_space = var.vnet_address_space
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# New Subnet
resource "azurerm_subnet" "internal" {
    name = "internal"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = var.subnet_address_space
}

module "server" {
    source = "./modules/terraform-azure-server"
    subnet_id = azurerm_subnet.internal.id
    resource_group_name = azurerm_resource_group.rg.name
    prefix = var.prefix
    location = var.location
    existing-kv-name = var.existing-kv-name
    existing-rg = var.existing-rg
    nsg_rule = var.nsg_rule
    nsg_name = var.nsg_name
    vmcount = var.vmcount
    os = {
    publisher = var.os.publisher
    offer = var.os.offer
    sku = var.os.sku
    version = var.os.version
    }
}

