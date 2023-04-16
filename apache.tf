
# Virtual Machine for each subnet
resource "azurerm_linux_virtual_machine" "vm" {
  count               = 3
  name                = "${var.group}-vm-apache${count.index}"
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

  # Update packages and install apache
  #   provisioner "remote-exec" {
  #     inline = [
  #       "sudo apt-get update",
  #       "sudo apt-get install apache2 -y",
  #     ]
  #   }
}
