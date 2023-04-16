# Main resource group for the network resources
resource "azurerm_resource_group" "vnets" {
  name     = "${var.group}-vnets"
  location = "eastus"
}

# Virtual network listening on 10.0.0.0/8, with three subnetworks
# - subnet1 (10.0.0.0/22)
# - subnet2 (10.0.4.0/22)
# - subnet3 (10.0.8.0/22)
resource "azurerm_virtual_network" "vnet_g" {
  name                = "${var.group}-vnet"
  location            = azurerm_resource_group.vnets.location
  resource_group_name = azurerm_resource_group.vnets.name
  address_space       = ["10.0.0.0/8"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/22"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.4.0/22"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.8.0/22"
  }
}

# Security Group with in/out rules for the next protocols:
# - HTTP (TCP/80)
# - HTTPS (TCP/443)
# - SSH (TCP/22)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.group}-nsg"
  location            = azurerm_resource_group.vnets.location
  resource_group_name = azurerm_resource_group.vnets.name

  security_rule {
    name                       = "http-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
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
    priority                   = 100
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
  subnet_id                 = element(azurerm_virtual_network.vnet_g.subnet.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Network interface to enable communication between resources in the VN
resource "azurerm_network_interface" "neti" {
  count               = 3
  name                = "${var.group}-nic-${count.index}"
  location            = azurerm_resource_group.vnets.location
  resource_group_name = azurerm_resource_group.vnets.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_virtual_network.vnet_g.subnet.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

# Virtual Machine for each subnet
resource "azurerm_linux_virtual_machine" "vm" {
  count               = 3
  name                = "${var.group}-vm-${count.index}"
  location            = azurerm_resource_group.vnets.location
  resource_group_name = azurerm_resource_group.vnets.name
  size                = "Standard_B1s"

  admin_username                  = var.vm_cred.user
  admin_password                  = var.vm_cred.pass
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[count.index],
  ]

  os_disk {
    name                 = "${var.group}-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # OS in wich the VM runs
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
