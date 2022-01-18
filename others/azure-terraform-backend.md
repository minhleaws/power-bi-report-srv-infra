## REF:
- https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli


## 1. Require. Create a service principal
## 2. Login as service principal

    ```sh
    export TENANT_ID='b3ae7b96-b97d-4266-9a34-35e27501008a'
    export CLIENT_ID='407840bc-c460-42ee-9883-e821d32ebf09'
    export CERT_PATH='keys/principals/terraform-service-principal.pem'
    export SUBSCRIPTION_ID='0555b3c4-b2eb-4e7f-b364-a251127cf2f3'
    export ST_ACCOUNT='powerbimgmtiacstacc'
    export RG='power-bi-mgmt-rg'
    ```

    ```sh
    az login --service-principal -u $CLIENT_ID -p $CERT_PATH --tenant $TENANT_ID
    [
      {
        "cloudName": "AzureCloud",
        "homeTenantId": "b3ae7b96-b97d-4266-9a34-35e27501008a",
        "id": "0555b3c4-b2eb-4e7f-b364-a251127cf2f3",
        "isDefault": true,
        "managedByTenants": [],
        "name": "Pay-As-You-Go",
        "state": "Enabled",
        "tenantId": "b3ae7b96-b97d-4266-9a34-35e27501008a",
        "user": {
          "name": "407840bc-c460-42ee-9883-e821d32ebf09",
          "type": "servicePrincipal"
        }
      }
    ]
    ```
## 3. Create storage account

    ```sh
    # To list locations
    az account list-locations -o table --subscription $SUBSCRIPTION_ID

    # Create MNG resource group
    az group create -l westeurope -n $RG --subscription $SUBSCRIPTION_ID
    az group list --query "[?location=='westeurope']" --subscription $SUBSCRIPTION_ID

    # Create Storage Account
    az storage account create --name $ST_ACCOUNT \
      --resource-group $RG \
      --https-only true \
      --access-tier Hot \
      --allow-blob-public-access false \
      --location westeurope \
      --subscription $SUBSCRIPTION_ID

    az storage account list -g $RG --query "[?location=='westeurope']" --subscription $SUBSCRIPTION_ID

    az storage container create --name tfstate \
    --account-name $ST_ACCOUNT \
    --public-access off \
    --resource-group $RG \
    --subscription $SUBSCRIPTION_ID

    az storage container list --account-name $ST_ACCOUNT --subscription $SUBSCRIPTION_ID
    ```
