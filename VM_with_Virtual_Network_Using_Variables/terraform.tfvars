os = {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
}

prefix = "terraform-winvm"

existing-rg = "thomcstone-kv"

existing-rg-location = "westus2"

existing-kv-name = "thomcstone-kv"

location = "westus2"

size = "Standard_B2s"

vnet_address_space = ["10.0.0.0/16"]

subnet_address_space = ["10.0.0.0/24"]


