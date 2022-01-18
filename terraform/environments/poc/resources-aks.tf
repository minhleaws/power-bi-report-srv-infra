## AKS CLUSTER
resource "azurerm_kubernetes_cluster" "power_bi" {
  name                = "${local.name_prefix}-aks-cluster1"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  dns_prefix          = "${local.name_prefix}-aks-cluster1-dns"

  # az aks get-versions --location <> --subscription <>
  kubernetes_version = "1.22.4"

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file("../../../keys/sshs/aks_ssh_key.pub")
    }
  }

  windows_profile {
    admin_username = "azureuser"
    admin_password = data.sops_file.secret.data["window_admin_password"]
  }

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_D2_v2" # https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series#dv2-series
    max_pods             = 110              #  Standard_D2_v2 does not support the storage account type Premium_LRS (ssh)
    orchestrator_version = "1.22.4"
    vnet_subnet_id       = azurerm_subnet.aks.id
  }

  network_profile {
    load_balancer_sku  = "Standard"
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.96.0.0/12"
    dns_service_ip     = "10.96.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  # addon_profile {
  #   ingress_application_gateway {
  #     enabled = true

  #   }
  # }
}

## CREATE NODE POOLS
## Windows Pool
# resource "azurerm_kubernetes_cluster_node_pool" "wb2s" {
#   name                  = "wb2s"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.power_bi.id
#   vm_size               = "Standard_B2s"
#   node_count            = 1
#   max_pods              = 110
#   orchestrator_version  = "1.22.4"
#   os_type               = "Windows"
#   vnet_subnet_id        = azurerm_subnet.aks.id
# }

resource "azurerm_kubernetes_cluster_node_pool" "wd2sv3" {
  name                  = "wd2sv3"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.power_bi.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 1
  max_pods              = 110
  orchestrator_version  = "1.22.4"
  os_type               = "Windows"
  vnet_subnet_id        = azurerm_subnet.aks.id
}

# Linux Pool
resource "azurerm_kubernetes_cluster_node_pool" "lds2v2" {
  name                  = "lds2v2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.power_bi.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  max_pods              = 110
  orchestrator_version  = "1.22.4"
  os_type               = "Linux"
  vnet_subnet_id        = azurerm_subnet.aks.id
}

## Prepare ServiceAccount & RBAC to connect the cluster with Azure Pipelines
## kubectl auth can-i create <api-resources> --as=system:serviceaccount:default:azure-pipelines-deploy
resource "kubernetes_secret" "azure_pipelines_deploy_token" {
  metadata {
    name = "azure-pipelines-deploy-token"
    annotations = {
      "kubernetes.io/service-account.name" = "azure-pipelines-deploy"
    }
  }
  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account" "azure_pipelines_deploy" {
  metadata {
    name      = "azure-pipelines-deploy"
    namespace = "default"
  }
  secret {
    name = kubernetes_secret.azure_pipelines_deploy_token.metadata.0.name
  }
}

resource "kubernetes_role" "azure_pipelines_deploy_role" {
  metadata {
    name      = "azure-pipelines-deploy-role"
    namespace = kubernetes_service_account.azure_pipelines_deploy.metadata[0].namespace
  }

  rule {
    api_groups = ["", "extensions", "apps", "networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["job", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role" "azure_pipelines_deploy_clusterrole" {
  metadata {
    name      = "azure-pipelines-deploy-clusterrole"
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_role_binding" "azure_pipelines_deploy_rolebinding" {
  metadata {
    name      = "azure-pipelines-deploy-rolebinding"
    namespace = kubernetes_service_account.azure_pipelines_deploy.metadata[0].namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.azure_pipelines_deploy_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.azure_pipelines_deploy.metadata[0].name
    namespace = kubernetes_service_account.azure_pipelines_deploy.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "azure_pipelines_deploy_clusterrolebinding" {
  metadata {
    name      = "azure-pipelines-deploy-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.azure_pipelines_deploy_clusterrole.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.azure_pipelines_deploy.metadata[0].name
    namespace = kubernetes_service_account.azure_pipelines_deploy.metadata[0].namespace
  }
}
