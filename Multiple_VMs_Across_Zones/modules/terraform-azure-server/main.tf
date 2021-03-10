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
#resource "azurerm_public_ip" "publicip" {
    #name = "${var.prefix}-ip"
    #resource_group_name = var.resource_group_name
    #location = var.location
    #allocation_method = "Dynamic"
#}

# New NIC with Public IP
resource "azurerm_network_interface" "nic" {
    count = var.vmcount
    name = "${var.prefix}-nic${format("%02d", 1 + count.index)}"
    location = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name = "${var.prefix}-nic${format("%02d", 1 + count.index)}"
        private_ip_address_allocation = "Dynamic"
        subnet_id = var.subnet_id
    }
}

# Get local Source IP address to use for security rule
data "external" "myipaddr" {
program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "azurerm_network_security_group" "nsg" {
    name = var.nsg_name
    location = var.location
    resource_group_name = var.resource_group_name

    dynamic security_rule {
        for_each = var.nsg_rule
        content {
            name = security_rule.value.name
            priority = security_rule.value.priority
            direction = security_rule.value.direction
            access = security_rule.value.access
            protocol = security_rule.value.protocol
            source_port_range = security_rule.value.source_port_range
            destination_port_range = security_rule.value.destination_port_range
            source_address_prefix = data.external.myipaddr.result.ip
            destination_address_prefix = security_rule.value.destination_address_prefix
        }
    }
}

# Attach the Network Security Group to NIC0 on the new VM
resource "azurerm_network_interface_security_group_association" "nsg-nic" {
    count = var.vmcount
    network_interface_id = element(azurerm_network_interface.nic.*.id, 1 + count.index)
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Retrieve local PowerShell script and set input variable
data "template_file" "init" {
    template = file("${path.module}/postdeploy.ps1")
}

resource "azurerm_windows_virtual_machine" "winvm" {
    count = var.vmcount
    name = "${var.prefix}-${format("%02d", 1 + count.index)}"
    location = var.location
    resource_group_name = var.resource_group_name
    network_interface_ids = [element(azurerm_network_interface.nic.*.id, 1 + count.index)]
    size = var.size
    admin_username = data.azurerm_key_vault_secret.kvsecret1.value
    admin_password = data.azurerm_key_vault_secret.kvsecret2.value
    custom_data = (base64encode(data.template_file.init.rendered))
    zone = count.index
    
    os_disk {
        name = "${var.prefix}-osdisk-${format("%02d", 1 + count.index)}"
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

# Azure Custom Script Extension for Script Deployment
resource "azurerm_virtual_machine_extension" "script" {
    count = var.vmcount
    name = "${var.prefix}-scriptext-${format("%02d", 1 + count.index)}"
    virtual_machine_id = element(azurerm_windows_virtual_machine.winvm.*.id, 1 + count.index)
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.9"

    settings = <<SETTINGS
        {
            "commandToExecute": "rename C:\\AzureData\\CustomData.bin postdeploy.ps1 & powershell -ExecutionPolicy Bypass -File C:\\AzureData\\postdeploy.ps1"

        }
SETTINGS

    lifecycle {
        ignore_changes = [ 
            settings,
        ]
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