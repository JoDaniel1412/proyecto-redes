
# Virtual Machine for the dns
resource "azurerm_virtual_machine" "dns-vm" {
  name = "${var.group}-vm-dns"
  //availability_set_id = azurerm_availability_set.avset.id
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[0],
  ]

  # OS in wich the VM runs
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.group}-osdisk-dns"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("./ssh/id_rsa.pub")
      path     = "/home/${var.vm_cred.user}/.ssh/authorized_keys"
    }
  }
  os_profile {
    computer_name  = var.group
    admin_username = var.vm_cred.user
  }
}

# Virtual Machine for the Apche servers
resource "azurerm_virtual_machine" "apache-vm" {
  count = 2
  name  = "${var.group}-vm-apache${count.index + 1}"
  //availability_set_id = azurerm_availability_set.avset.id
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[count.index + 1],
  ]

  # OS in wich the VM runs
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.group}-osdisk-apache${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Certificates
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("./ssh/id_rsa.pub")
      path     = "/home/${var.vm_cred.user}/.ssh/authorized_keys"
    }
  }

  os_profile {
    computer_name  = var.group
    admin_username = var.vm_cred.user
  }
}
