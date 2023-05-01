# Virtual Machine for the Web servers
resource "azurerm_virtual_machine" "web-vm" {
  count               = 3
  name                = count.index < 2 ? "${var.group}-web-vm${count.index + 1}" : "${var.group}-open-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  availability_set_id = azurerm_availability_set.avset.id
  vm_size             = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.neti.*.id[count.index],
  ]

  # OS in wich the VM runs
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = count.index < 2 ? "${var.group}-osdisk-web-vm${count.index}" : "${var.group}-osdisk-open-vm"
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
    custom_data    = count.index < 2 ? filebase64("./web/cloud-init${count.index + 1}.txt") : null
  }
}
