resource "azuredevops_project" "power_bi" {
  name        = "Power Bi Reporting Services"
  description = "Power Bi Reporting Services"
}

## REF: https://github.com/HealisticEngineer/Docker
resource "azuredevops_git_repository" "pbirs" {
  project_id = azuredevops_project.power_bi.id
  name       = "pbirs"
  initialization {
    init_type = "Clean"
  }
}

## Create ACR
resource "azurerm_container_registry" "power_bi" {
  name                = "powerbipoc" # powerbipoc.azurecr.io
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  sku                 = "Standard" # Premium allow private network connection
  admin_enabled       = false
}

## Allow AKS Pull Image from ACR
resource "azurerm_role_assignment" "attach_acr" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.power_bi.id
  principal_id         = azurerm_kubernetes_cluster.power_bi.kubelet_identity[0].object_id
}

## Create Service Princial
### Allow Pull & Push Images to ACR
resource "azuread_application" "acr" {
  display_name = "${local.name_prefix}-acr-service-principal"
}

resource "azuread_service_principal" "acr" {
  application_id = azuread_application.acr.application_id
  description    = "ACR Service Principal"
}

## https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal
## https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli#service-principal
## https://docs.microsoft.com/en-us/azure/container-registry/container-registry-roles?tabs=azure-cli
resource "azurerm_role_assignment" "power_bi_registry_push" {
  scope                = azurerm_container_registry.power_bi.id
  role_definition_name = "acrpush"
  principal_id         = azuread_service_principal.acr.object_id
}

## Create AZ DevOps Service connection, connect with ACR
resource "azuread_service_principal_password" "acr" {
  display_name         = "rbac"
  service_principal_id = azuread_service_principal.acr.object_id
}

resource "azuredevops_serviceendpoint_dockerregistry" "powerbipoc" {
  project_id            = azuredevops_project.power_bi.id
  service_endpoint_name = "${azurerm_container_registry.power_bi.name}.azurecr.io"
  description           = "ACR Service Endpoint"
  docker_registry       = "https://${azurerm_container_registry.power_bi.name}.azurecr.io/v1"
  docker_username       = azuread_application.acr.application_id       # Application (client) ID
  docker_password       = azuread_service_principal_password.acr.value # Client secret value
  registry_type         = "Others"
}

## docker login powerbipoc.azurecr.io --username <docker_username> --password <docker_password>
## docker tag nginx:alpine powerbipoc.azurecr.io/nginx:alpine-1
## docker push powerbipoc.azurecr.io/nginx:alpine-1
# output "docker_username" {
#   value = azuread_application.acr.application_id
# }

# output "docker_password" {
#   sensitive = true
#   value = azuread_service_principal_password.acr.value
# }

## Create Kubernetes Service Connection
resource "azuredevops_serviceendpoint_kubernetes" "powerbipoc" {
  project_id            = azuredevops_project.power_bi.id
  service_endpoint_name = azurerm_kubernetes_cluster.power_bi.kube_config.0.host
  description           = "AKS Service Endpoint"
  apiserver_url         = azurerm_kubernetes_cluster.power_bi.kube_config.0.host
  authorization_type    = "ServiceAccount"

  service_account {
    token   = base64encode("${kubernetes_secret.azure_pipelines_deploy_token.data["token"]}")
    ca_cert = base64encode("${kubernetes_secret.azure_pipelines_deploy_token.data["ca.crt"]}")
  }
}

## terraform output -json
# output "token" {
#   sensitive = true
#   value     = base64encode("${kubernetes_secret.azure_pipelines_deploy_token.data["token"]}")
# }

# output "ca_cert" {
#   sensitive = true
#   value     = base64encode("${kubernetes_secret.azure_pipelines_deploy_token.data["ca.crt"]}")
# }


## Create pipepline
resource "azuredevops_build_definition" "pbirs" {
  project_id = azuredevops_project.power_bi.id
  name       = "pbirs"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.pbirs.id
    branch_name = azuredevops_git_repository.pbirs.default_branch
    yml_path    = "azure-pipeline.yaml"
  }
}
