output "instance_ip_addr" {
  value = azurerm_public_ip.pip.ip_address
}
output "public_ip_address" {
  value = azurerm_public_ip.vm-pip.ip_address
}

