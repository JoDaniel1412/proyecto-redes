# Main resource group for the resources
resource "azurerm_resource_group" "main" {
  name     = "${var.group}-resgroup"
  location = var.location["name"]
}

# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name                = "${var.group}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
}
