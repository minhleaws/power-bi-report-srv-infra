1. Generate certificate

```sh
openssl req -newkey rsa:4096 -nodes -keyout "terraform-service-principal.key" -out "terraform-service-principal.csr" -subj "/CN=terraform-service-principal"
openssl x509 -signkey "terraform-service-principal.key" -in "terraform-service-principal.csr" -req -days 365 -out "terraform-service-principal.crt"
openssl pkcs12 -export -out "terraform-service-principal.pfx" -inkey "terraform-service-principal.key" -in "terraform-service-principal.crt"
```

2. Creating the Application and Service Principal
3. Upload Cert
4. Subscription > IAM > Role Assignment > Add role owner > Member > terraform-service-principal


## Configuring a User or Service Principal for managing Azure Active Directory
https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration
https://docs.microsoft.com/en-us/graph/migrate-azure-ad-graph-configure-permissions
