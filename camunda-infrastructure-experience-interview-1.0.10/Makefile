# WARNING: You don't need to edit this file

SH := /bin/bash

.EXPORT_ALL_VARIABLES:
CAMUNDA_CHALLENGE_LOG_FILE := $(if $(CAMUNDA_CHALLENGE_LOG_FILE),$(CAMUNDA_CHALLENGE_LOG_FILE),$(shell mktemp))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## Display this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help

start-log:
	@echo "Saving logfile to: $(CAMUNDA_CHALLENGE_LOG_FILE)"

end-log:
	./scripts/parselog.sh

apply-cluster:  ## Apply the 01-cluster-create Terraform workspace
	./scripts/apply.sh 01-cluster-create

apply-deploy:  ## Apply the 02-app-deploy Terraform workspace
	./scripts/apply.sh 02-app-deploy

apply: apply-cluster apply-deploy ## Apply both Terraform workspaces, one after another

check-todos:  ## Check all TODOs were addressed
	./scripts/check-todos.sh

check-tools: ## Check all required tools are installed
	./scripts/check-tools.sh

test:  ## Check that the S3 app works correctly and the Terraform outputs are correct
	./scripts/test.sh

destroy:  ## Destroy both Terraform workspaces, one after another
	./scripts/destroy.sh

localstack-start:  ## Starts Localstack locally with all the correct configurations
	./scripts/localstack.sh start

localstack-stop:  ## Stops Localstack
	./scripts/localstack.sh stop

full-test:  ## Run the full testing suite
	$(MAKE) start-log
	$(MAKE) localstack-start || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) check-todos || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) check-tools || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) apply || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) test || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) destroy || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) localstack-stop || ( $(MAKE) end-log ; exit 1 )
	$(MAKE) end-log
