# Create a load balancer
resource "azurerm_lb" "lb" {
  name                = "${var.group}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.group}-frontend-ip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create backend pools
resource "azurerm_lb_backend_address_pool" "pool" {
  name            = "${var.group}-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool-aso" {
  count                   = 3
  network_interface_id    = element(azurerm_network_interface.neti.*.id, count.index)
  ip_configuration_name   = "ip-config${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

# # Create a load balancer rule
# resource "azurerm_lb_rule" "rule" {
#   name                           = "${var.group}-lb-rule"
#   loadbalancer_id                = azurerm_lb.lb.id
#   protocol                       = "Tcp"
#   frontend_port                  = 80
#   backend_port                   = 80
#   frontend_ip_configuration_name = "${var.group}-frontend-ip"
# }

# resource "azurerm_availability_set" "avset" {
#   name                         = "avset"
#   location                     = azurerm_resource_group.main.location
#   resource_group_name          = azurerm_resource_group.main.name
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
# }
