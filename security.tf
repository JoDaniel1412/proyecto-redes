
# Security Group with in/out rules for the next protocols:
# - HTTP (TCP/80)
# - HTTPS (TCP/443)
# - SSH (TCP/22)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.group}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "http-in"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
  name                       = "proxy-in"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3128"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

security_rule {
  name                       = "proxy-out"
  priority                   = 100
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "3128"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

  security_rule {
    name                       = "https-in"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh-in"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "any-out"
    priority                   = 103
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Adds the security rules to the subnetworks
resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
  count                     = 3
  subnet_id                 = element(azurerm_virtual_network.vnet.subnet.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}
