terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.90.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.8"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.14.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "power-bi-mgmt-rg"
    storage_account_name = "powerbimgmtiacstacc"
    container_name       = "tfstate"
    key                  = "poc.terraform.tfstate"

    ## authenticating using a Service Principal with a Client Certificate 
    subscription_id             = "0555b3c4-b2eb-4e7f-b364-a251127cf2f3"                     # Pay-As-You-Go
    client_id                   = "407840bc-c460-42ee-9883-e821d32ebf09"                     # Application (client) ID | terraform-service-principal
    client_certificate_path     = "../../../keys/principals/terraform-service-principal.pfx" # Git Ignore
    client_certificate_password = ""                                                         # PFX export pass. Empty
    tenant_id                   = "b3ae7b96-b97d-4266-9a34-35e27501008a"                     # Directory (tenant) ID 
  }
}

provider "azurerm" {
  features {}

  subscription_id             = "0555b3c4-b2eb-4e7f-b364-a251127cf2f3"                     # Pay-As-You-Go
  client_id                   = "407840bc-c460-42ee-9883-e821d32ebf09"                     # Application (client) ID | terraform-service-principal
  client_certificate_path     = "../../../keys/principals/terraform-service-principal.pfx" # Git Ignore
  client_certificate_password = ""                                                         # PFX export pass. Empty
  tenant_id                   = "b3ae7b96-b97d-4266-9a34-35e27501008a"                     # Directory (tenant) ID  
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/dskolli/"
  personal_access_token = data.sops_file.secret.data["azdevops_personal_access_token"]
}

provider "azuread" {
  client_id                   = "407840bc-c460-42ee-9883-e821d32ebf09"                     # Application (client) ID | terraform-service-principal
  client_certificate_path     = "../../../keys/principals/terraform-service-principal.pfx" # Git Ignore
  client_certificate_password = ""                                                         # PFX export pass. Empty
  tenant_id                   = "b3ae7b96-b97d-4266-9a34-35e27501008a"                     # Directory (tenant) ID  
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.power_bi.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.power_bi.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.power_bi.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.power_bi.kube_config.0.cluster_ca_certificate)
}
