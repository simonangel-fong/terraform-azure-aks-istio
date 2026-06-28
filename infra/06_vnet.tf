# vnet.tf


# ##############################
# VNet
# ##############################
resource "azurerm_virtual_network" "vnet" {
  name                = local.common_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  address_space = [local.vnet_cidr]

  tags = merge(
    local.default_tags,
    { Name = local.common_name }
  )
}

# ##############################
# AKS subnet
# ##############################
resource "azurerm_subnet" "this" {
  name                 = local.common_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [local.subnet_cidr]
}
