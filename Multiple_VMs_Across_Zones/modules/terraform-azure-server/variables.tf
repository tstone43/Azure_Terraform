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

variable "nsg_rule" {
    description = "Network Security Groups to Create"
    type = list(object({
        name = string
        priority = number
        direction = string
        access = string
        protocol = string
        source_port_range = string
        destination_port_range = string
        source_address_prefix = string
        destination_address_prefix = string
    }))
}

variable "nsg_name" {
    description = "Name of the Network Security Group"
    type = string
}

variable "vmcount" {
    description = "number of VMs to deploy"
    type = number
    validation {
        condition = var.vmcount < 4
        error_message = "This configuration only supports up to 3 VMs."
    }
}
