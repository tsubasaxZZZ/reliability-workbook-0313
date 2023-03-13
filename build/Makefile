TERRAFORM_TARGET := $(shell find . -type f \( -name 'variables.tf' -o -name main.tf \) -prune -o -type f -name '*.tf' -print)

.PHONY: terraform-plan
terraform-plan:
	terraform plan -input=false -no-color -out tfplan $(addprefix -target local_file.,$(basename $(notdir $(TERRAFORM_TARGET))))

.PHONY: clean
clean:
	rm -f tfplan
	rm -f artifacts/*.workbook
