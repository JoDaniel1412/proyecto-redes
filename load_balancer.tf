# Create a load balancer
resource "azurerm_lb" "lb" {
  name                = "${var.group}-load-balancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.group}-lb-frontend-ip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create backend pools
resource "azurerm_lb_backend_address_pool" "pool" {
  name            = "${var.group}-lb-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.group}-lb-probe"
  protocol        = "Tcp"
  port            = 80
}

# Create a load balancer rule
resource "azurerm_lb_rule" "rule" {
  name                           = "${var.group}-lb-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.group}-lb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
}

resource "azurerm_network_interface_backend_address_pool_association" "backendpool" {
  count                   = 3
  network_interface_id    = element(azurerm_network_interface.neti.*.id, count.index)
  ip_configuration_name   = "ip-config${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}
