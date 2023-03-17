# Get only the list of files that will be used to generate the Workbook
TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)
ARM_TEMPLATE_JSON = $(wildcard artifacts/*.json)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: build-workbook
build-workbook: ## Execute terraform plan
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))
	terraform apply -no-color tfplan
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.armparameter_,$(basename $(notdir $(TERRAFORM_TARGET))))
	terraform apply -no-color tfplan

.PHONY: generate-shell-script
generate-shell-script: ## Generate deploy to Azure command
	rm -f deploy_command
	for file in $(ARM_TEMPLATE_JSON); do \
		filename=$$(basename $$file); \
		echo "az deployment group create -g \$$resource_group_name --template-uri \$$base_url/build/main.bicep --parameters \$$base_url/artifacts/$$filename" >> deploy_command; \
	done
	sed -e '/__REPLACE_DEPLOY_COMMAND__/r deploy_command' -e '/__REPLACE_DEPLOY_COMMAND__/d' deploy-workbook.sh.template > ../scripts/deploy-workbook.sh

.PHONY: clean
clean: ## Remove generated files
	rm -f tfplan
	rm -rf artifacts/
	rm -f deploy_command
	rm -f ../scripts/deploy-workbook.sh
