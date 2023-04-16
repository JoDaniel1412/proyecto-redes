# Virtual network listening on 10.0.0.0/8, with three subnetworks
# - subnet1 (10.0.0.0/22)
# - subnet2 (10.0.4.0/22)
# - subnet3 (10.0.8.0/22)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.group}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
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

# Adds the security rules to the subnetworks
resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
  count                     = 3
  subnet_id                 = element(azurerm_virtual_network.vnet.subnet.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Network interface to enable communication between resources in the VN
resource "azurerm_network_interface" "neti" {
  count               = 3
  name                = "${var.group}-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_virtual_network.vnet.subnet.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

# Virtual Machine for each subnet
resource "azurerm_linux_virtual_machine" "vm" {
  count               = 3
  name                = "${var.group}-vm-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
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
