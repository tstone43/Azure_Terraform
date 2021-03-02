variable "prefix" {
    type = string
    description = "Prefix to be used in name for multiple resources"
    default = "terraform-winvm"
}

variable "location" {
    type = string
    description = "Azure location for VM and VNET"
    default = "westus2"
}

variable "vnet_address_space" {
    type = list(any)
    description = "Address space for Virtual Network"
    default = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
    type = list(any)
    description = "Address space for subnet"
    default = ["10.0.0.0/24"]
}

variable "existing-rg" {
    type = string
    description = "Name of existing resource group where Key Vault resides goes here"
}

variable "existing-kv-name" {
    type = string
    description = "Name of existing Key Vault goes here"
}

variable "os" {
    description = "OS Image to Deploy"
    type = object({
        publisher = string
        offer = string
        sku = string
        version = string
    })
}





