data "sops_file" "secret" {
  source_file = "../../../sops/secrets.${local.environment}.enc.yaml"
}

data "azurerm_kubernetes_cluster" "power_bi" {
  name                = "${local.name_prefix}-aks-cluster1"
  resource_group_name = local.resource_group
}
