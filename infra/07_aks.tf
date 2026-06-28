# # main.tf

# ##############################
# AKS Cluster
# ##############################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.common_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  kubernetes_version = local.aks_versions

  # ####################
  # identity
  # ####################
  identity {
    type = "SystemAssigned"
  }
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ####################
  # default (system) node pool
  # ####################
  default_node_pool {
    name           = "system"
    vnet_subnet_id = azurerm_subnet.this.id
    vm_size        = local.node_pool.vm_size
    node_count     = local.node_pool.node_count

    auto_scaling_enabled = local.node_pool.auto_scaling
    min_count            = local.node_pool.auto_scaling ? local.node_pool.min_count : null
    max_count            = local.node_pool.auto_scaling ? local.node_pool.max_count : null
  }

  # ####################
  # networking
  # ####################
  dns_prefix = local.common_name
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard" # lb provision
  }

  tags = merge(
    local.default_tags,
    { Name = local.common_name }
  )
}
