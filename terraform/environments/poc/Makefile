.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Show this help output
	@echo 'Usage: make <target>'
	@@awk 'BEGIN {FS = ":.*?#> "} /^[a-zA-Z_-]+:.*?#> / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo 'Targets'
	@@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initial Terraform state
	terraform init --var-file=../cross-env.tfvars

plan: ## Showing infrastructure plan
	terraform plan --var-file=../cross-env.tfvars

apply: ## Provisioning infrastructure
	terraform apply --var-file=../cross-env.tfvars

destroy: ## Destroy/cleanup infrastructure
	terraform destroy --var-file=../cross-env.tfvars

fmt:
	terraform fmt -recursive
