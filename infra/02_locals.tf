# locals.tf

locals {

  # ####################
  # Metadata
  # ####################
  project_name = "aks-istio"
  common_name  = "${local.project_name}-${var.env}"
  location     = "eastus"

  default_tags = {
    environment = var.env
    project     = local.project_name
    managed_by  = "terraform"
  }

  resource_group_name = "rg-${local.common_name}"

  # ####################
  # Networking
  # ####################
  vnet_cidr   = "10.10.0.0/16"
  subnet_cidr = "10.10.0.0/20" # 4,091

  # ####################
  # Aks
  # ####################
  aks_versions       = "1.35"
  aks_service_cidr   = "10.0.64.0/20"
  aks_dns_service_ip = "10.0.64.10"

  node_pool = {
    vm_size      = "standard_d2s_v7"
    node_count   = 2
    min_count    = 2
    max_count    = 3
    auto_scaling = true
  }
}
