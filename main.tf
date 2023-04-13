#for an existing RG
data "azurerm_resource_group" "example" {
  name = "urrg"
  # location = "eastus"
}

#for an existing Azure LB
data "azurerm_lb" "appbalancer" {
  name                = "mylb"
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  address_space       = ["172.24.0.0/20"]

}

resource "azurerm_subnet" "examplesn" {

  name                 = "testsubnet"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["172.24.0.0/24"]
}

#creates a new NIC
resource "azurerm_network_interface" "self" {
  name                = "ni-123"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "ni-ip-123"
    subnet_id                     = azurerm_subnet.examplesn.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    resource.azurerm_virtual_network.example
  ]
}

resource "azurerm_lb_nat_rule" "lb_nat" {
  resource_group_name            = "common-cus-fnd"
  loadbalancer_id                = data.azurerm_lb.appbalancer.id
  name                           = "vm-inbound-rp_priority"
  protocol                       = "Tcp"
  frontend_port                  = 1234
  backend_port                   = 3389
  frontend_ip_configuration_name = data.azurerm_lb.appbalancer.frontend_ip_configuration[0].name
  #   depends_on = [
  #     #data.azurerm_resource_group.appgrp,
  #     azurerm_lb.tier1-lb
  #   ]
}

#Associated a nat rule to an existing LB
resource "azurerm_network_interface_nat_rule_association" "nat_association" {
  network_interface_id  = azurerm_network_interface.self.id
  ip_configuration_name = azurerm_network_interface.self.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.lb_nat.id
  depends_on = [
    azurerm_lb_nat_rule.lb_nat,
    azurerm_network_interface.self
  ]

}
