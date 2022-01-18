# power-bi-report-srv-infra
Power BI Report Server Infrastructure

## Before you begin

### 1. Import PGP Private key

Note: `power-bi.pgp.private.asc` file is not public in Git repository

```sh
mv /path/to/power-bi.pgp.private.asc ./sops/power-bi.pgp.private.asc
gpg --import ./sops/power-bi.pgp.public.asc
gpg --import ./sops/power-bi.pgp.private.asc
```

### 2. Key files & credentials

Note: `keys` directory is not public in Git repository

```sh
mv /path/to/keys ./keys
```

Structure Layout:

```sh
.
├── keys                                                   # Git Ignore
│   ├── principals
│   │   ├── pfx_export_pass.txt
│   │   ├── terraform-service-principal.crt
│   │   ├── terraform-service-principal.csr
│   │   ├── terraform-service-principal.key
│   │   ├── terraform-service-principal.pem
│   │   └── terraform-service-principal.pfx
│   └── sshs
│       ├── aks_ssh_key
│       └── aks_ssh_key.pub
├── LICENSE
├── others
│   ├── azure-acr-authenticate.md
│   ├── azure-aks-authenticate.md
│   ├── azure-aks-ssh-node.md
│   ├── azure-terraform-authentication.md
│   └── azure-terraform-backend.md
├── README.md
├── sops
│   ├── Makefile
│   ├── power-bi.pgp.private.asc                            # Git Ignore
│   ├── power-bi.pgp.public.asc
│   ├── secrets.poc.dec.yaml
│   └── secrets.poc.enc.yaml
└── terraform
    ├── environments
    │   ├── cross-env.tfvars
    │   └── poc
    │       ├── data.tf
    │       ├── Makefile
    │       ├── providers.tf
    │       ├── resources-aks.tf
    │       ├── resources-az-devops.tf
    │       ├── resources-cores.tf
    │       └── variables.tf
    └── modules
        ├── aks
        │   └── main.tf
        └── network
            └── main.tf
```

## Infrastructure Provisioning

### How To

```sh
cd terraform/environments/poc
make init    # initial
make plan    # see plan
make apply   # apply plan
make destroy # clean-up environment
```

### PoC Infrastructure

- resource group: power-bi-poc-rg
- network: power-bi-poc-vnet / 10.0.0.0/16  
  subnets: 
  - kubernetes-pod-snet / 10.0.124./22
- aks cluster name: power-bi-poc-aks-cluster1
  - node pools:
    - default: Standard_D2_v2 (linux container, required)
    - lds2v2: Standard_DS2_v2 (linux container, optional)
    - wd2sv3: Standard_D2s_v3 (windows container, optional)
- container registry: powerbipoc.azurecr.io
- azure devops project: https://dev.azure.com/dskolli/Power%20Bi%20Reporting%20Services
