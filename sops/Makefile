.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Show this help output
	@echo 'Usage: make <target> env=<env>'
	@echo
	@echo 'Environments'
	@@awk 'BEGIN {FS = ":.*?#> "} /^[a-zA-Z_-]+:.*?#> / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo
	@echo 'Targets'
	@@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

poc: #> POC environment


encrypt: ## Encrypt secrets data
	sops -e secrets.$(env).dec.yaml > secrets.$(env).enc.yaml

decrypt: ## Encrypt secrets data
	sops -d secrets.$(env).enc.yaml
