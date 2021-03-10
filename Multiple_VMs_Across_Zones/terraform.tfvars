existing-rg = "thomcstone-kv"
existing-kv-name = "thomcstone-kv"
os = {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
}

nsg_rule =[
    {
    name = "http"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "80"
    destination_address_prefix = "*"
    },
    {
    name = "rdp"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_range = "3389"
    destination_address_prefix = "*"
    }
]

nsg_name = "Allow_HTTP_and_RDP"

vmcount = "2"