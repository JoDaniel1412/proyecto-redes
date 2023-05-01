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
    name           = "${var.group}-subnet1"
    address_prefix = "10.0.0.0/22"
  }

  subnet {
    name           = "${var.group}-subnet2"
    address_prefix = "10.0.4.0/22"
  }

  subnet {
    name           = "${var.group}-subnet3"
    address_prefix = "10.0.8.0/22"
  }
}

# Network interface to enable communication between resources in the VN
resource "azurerm_network_interface" "neti" {
  count               = 3
  name                = "${var.group}-neti${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ip-config${count.index + 1}"
    subnet_id                     = element(azurerm_virtual_network.vnet.subnet.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = count.index < 2 ? null : azurerm_public_ip.vm-pip.id
  }
}
