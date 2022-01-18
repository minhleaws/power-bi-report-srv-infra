locals {
  environment    = "poc"
  name_prefix    = "${var.project}-${local.environment}"
  resource_group = "${local.name_prefix}-rg"
}

// RESOURCE GROUP
resource "azurerm_resource_group" "core" {
  name     = local.resource_group
  location = var.location
}

// NETWORKING
// virtual network > subnets
resource "azurerm_virtual_network" "core" {
  name                = "${local.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
}

resource "azurerm_subnet" "aks" {
  name                 = "kubernetes-pod-snet"
  address_prefixes     = ["10.0.124.0/22"]
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
}

// NatGW Public IP > NatGW > Associate subnets
resource "azurerm_public_ip" "aks_natgw" {
  name                = "${local.name_prefix}-aks-natgw-ip"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "aks" {
  name                    = "${local.name_prefix}-aks-natgw"
  location                = azurerm_resource_group.core.location
  resource_group_name     = azurerm_resource_group.core.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "aks" {
  nat_gateway_id       = azurerm_nat_gateway.aks.id
  public_ip_address_id = azurerm_public_ip.aks_natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.aks.id
}
