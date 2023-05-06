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

  provisioner "remote-exec" {
    inline = count.index < 2 ? [
      "chmod +x /home/azureuser/",
      "cd /home/azureuser/",
      "wget https://raw.githubusercontent.com/JocxanS7/Redes/master/comandos.sh",
      "sed -i 's/\"IP_PUBLIC_MAQUINE_VIRTUAL\"/\"${azurerm_public_ip.vm-pip.ip_address}\"/g' comandos.sh",
      "sudo chmod +x /home/azureuser/comandos.sh",
      "bash /home/azureuser/comandos.sh"
      

      
    ] : null
    connection { 
      type        = count.index < 2 ? "ssh" : null
      host        = count.index < 2 ? "${azurerm_public_ip.vm-pip.ip_address}" : null
      user        = count.index < 2 ? var.vm_cred.user : null
      private_key = count.index < 2 ? file("./ssh/id_rsa") : null
    }
  }
}


