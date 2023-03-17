# Get only the list of files that will be used to generate the Workbook
TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)
ARM_TEMPLATE_JSON = $(filter-out artifacts/azuredeploy.json,$(wildcard artifacts/*.json))
WORKBOOK_JSON = $(wildcard artifacts/*.workbook)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: all
all: build-workbook build-bicep generate-shell-script ## Execute all steps

.PHONY: build-workbook
build-workbook: ## Execute terraform plan
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))
	terraform apply -no-color tfplan
	mkdir -p artifacts
	(cd artifacts && ls *.workbook > workbook_filelist)
#	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.armparameter_,$(basename $(notdir $(TERRAFORM_TARGET))))
#	terraform apply -no-color tfplan

.PHONY: build-bicep
build-bicep: ## Build Bicep files
	mkdir -p artifacts
	az bicep build -f main.bicep --stdout > azuredeploy.json
	mv azuredeploy.json artifacts

.PHONY: generate-shell-script
generate-shell-script: ## Generate deploy to Azure command
	rm -f deploy_command
	mkdir -p scripts
	for file in $(ARM_TEMPLATE_JSON); do \
		filename_base=$$(basename $$file .parameters.json); \
		filename=$$(basename $$file); \
		echo "az deployment group create -g \$$resource_group_name --template-uri \$$base_url/artifacts/azuredeploy.json --parameters \$$base_url/artifacts/$$filename --query 'properties.outputs.resource_id.value' -o json > $${filename_base}_id" >> deploy_command; \
	done
	sed -e '/__REPLACE_DEPLOY_COMMAND__/r deploy_command' -e '/__REPLACE_DEPLOY_COMMAND__/d' ./deploy-workbook.sh.template > ./scripts/deploy-workbook.sh

.PHONY: generate-shell-script2
generate-shell-script2: ## Generate deploy to Azure command
	rm -f deploy_command
	mkdir -p scripts
	for file in $(WORKBOOK_JSON); do \
		filename_base=$$(basename $$file .workbook); \
		filename=$$(basename $$file); \
		echo "az deployment group create -g \$$resource_group_name --template-uri \$$base_url/artifacts/azuredeploy.json --parameters serializedData=$$filename --parameters name=$$filename_base --query 'properties.outputs.resource_id.value' -o json > $${filename_base}_id" >> deploy_command; \
	done
	sed -e '/__REPLACE_DEPLOY_COMMAND__/r deploy_command' -e '/__REPLACE_DEPLOY_COMMAND__/d' ./deploy-workbook.sh.template > ./scripts/deploy-workbook.sh


.PHONY: clean
clean: ## Remove generated files
	rm -f tfplan
	rm -rf ./artifacts/
	rm -f ./deploy_command
	rm -rf ./scripts/
