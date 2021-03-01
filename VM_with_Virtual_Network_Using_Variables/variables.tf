variable "os" {
    description = "OS Image to Deploy"
    type = object({
        publisher = string
        offer = string
        sku = string
        version = string
    })
}

variable "prefix" {
    type = string
    description = "Prefix to be used in name for multiple resources"
    default = "terraform-winvm"
}

variable "existing-rg" {
    type = string
    description = "Name of existing resource group where Key Vault resides goes here"
}

variable "existing-rg-location" {
    type = string
    description = "Existing location for resource group above goes here"
}

variable "existing-kv-name" {
    type = string
    description = "Name of existing Key Vault goes here"
}

variable "location" {
    type = string
    description = "Azure location for VM and VNET"
    default = "westus2"
}

variable "storage_account_type" {
    type = map
    description = "Disk type premium in primary location and standard in DR location" 

    default = {
        westus2 = "Premium_LRS"
        eastus = "Standard_LRS"
    }
}

variable "size" {
    type = string
    description = "The size of the VM to deploy"
    default = "Standard_B2s"
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