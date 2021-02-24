variable "prefix" {
    default = "terraform-winvm"
}

resource "azurerm_resource_group" "rg" {
    name = "{var.prefix}-rg"
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