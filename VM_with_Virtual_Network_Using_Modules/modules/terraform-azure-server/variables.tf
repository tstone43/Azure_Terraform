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
}

variable "resource_group_name" {
    type = string
    description = "Name of the Resource Group to deploy the Virtual Machine"
}

variable "existing-rg" {
    type = string
    description = "Name of existing resource group where Key Vault resides goes here"
}

variable "existing-kv-name" {
    type = string
    description = "Name of existing Key Vault goes here"
}

variable "location" {
    type = string
    description = "Azure location for VM and VNET"
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

variable "subnet_id" {
    type = string
    description = "ID of the subnet to assign to the Network Interface resource"
}