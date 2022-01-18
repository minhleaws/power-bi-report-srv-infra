https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli

```sh
docker login powerbipoc.azurecr.io --username <Application (client) ID> --password <Service principal secret>
docker tag nginx:alpine powerbipoc.azurecr.io/nginx:alpine
docker push powerbipoc.azurecr.io/nginx:alpine
```