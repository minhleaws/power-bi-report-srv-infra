1. Required. 
2. Authenticate

    ```sh
    export SUBSCRIPTION_ID='0555b3c4-b2eb-4e7f-b364-a251127cf2f3'    
    export RG='power-bi-poc-rg'
    export AKS_CLUSTER='power-bi-poc-aks-cluster1'
    ```

    ```sh
    az aks get-credentials --resource-group $RG --name $AKS_CLUSTER --subscription $SUBSCRIPTION_ID
    ```

3. Verify

    ```sh
    kubectl config current-context
    kubectl cluster-info
    ```
