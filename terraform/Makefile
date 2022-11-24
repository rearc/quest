args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$($a)))

plan_args =
apply_args =
destroy_args =
cost_args =
validate_args =
docs_args =
lint_args =
sec_args =

TASKS = \
		plan \
		apply \
		destroy \
		cost \
		validate \
		docs \
		lint \
		sec

.PHONY: $(TASKS)

help:
	@echo
	@echo "make ACTION env=ENVIRONMNET"
	@echo
	@echo "ACTION				COMMENT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Note that workspaces are created the first time you run \`plan\`."

plan: ## Selects or creates the workspace for the specified environment and runs terraform plan
	terraform fmt -recursive
	terraform plan -out=plan.tfplan
	$(MAKE) validate

apply: ## Selects the workspace for the specified environment and run terraform apply.
	terraform fmt -recursive
	terraform apply
	$(MAKE) validate

destroy: ## Selects the workspace for the specified environment and run terraform destroy.
	terraform fmt -recursive
	terraform destroy
	$(shell echo {} > infracost.json)

init: ## Initialize Terraform
	terraform init
	tflint --init

init-upgrade: ## Selects or creates the workspace for the specified environment and runs terraform init -upgrade
	terraform init -upgrade
	tflint --init

cost: ## Estimates the cost of infrastructure. Runs automatically with plan and apply
	infracost breakdown --path=./ --format=json --out-file=infracost.json

validate: ## Selects the workspace for the specified environment and runs terraform validate.
## Runs automatically with plan and apply
	terraform fmt -recursive
	terraform validate
	$(MAKE) docs
	$(MAKE) lint
	$(MAKE) sec

docs: ## Updates docs in README.md. Runs automatically with validate
	terraform-docs markdown . --output-file=README.md

lint: ## Lints Terraform. Runs automatically with validate
	tflint --enable-plugin=aws

sec: ## Verifies security of Terraform resources. Runs automatically with validate
	tfsec .