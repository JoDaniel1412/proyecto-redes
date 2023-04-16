
# Virtual Machine for the dns
resource "azurerm_linux_virtual_machine" "dns-vm" {
  name                = "${var.group}-vm-dns"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"

  admin_username                  = var.vm_cred.user
  admin_password                  = var.vm_cred.pass
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[0],
  ]

  os_disk {
    name                 = "${var.group}-osdisk-dns"
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

# Virtual Machine for the Apche servers
resource "azurerm_linux_virtual_machine" "apache-vm" {
  count               = 2
  name                = "${var.group}-vm-apache${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"

  admin_username                  = var.vm_cred.user
  admin_password                  = var.vm_cred.pass
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[count.index + 1],
  ]

  os_disk {
    name                 = "${var.group}-osdisk-apache${count.index + 1}"
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

  # Update packages and install apache
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 -y",
    ]
  }
}
