args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$($a)))

apply_args =
cost_args =
destroy_args =
docs_args =
lint_args =
plan_args =
sec_args =
validate_args =

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

apply: ## Runs terraform apply.
	terraform fmt -recursive
	terraform apply
	$(MAKE) validate

cost: ## Estimates the cost of infrastructure. Runs automatically with plan and apply
	terraform fmt -recursive
	infracost breakdown --path=./ --format=json --out-file=infracost.json

destroy: ## Runs terraform destroy.
	terraform fmt -recursive
	terraform destroy
	$(shell echo {} > infracost.json)

docs: ## Updates docs in README.md. Runs automatically with validate
	terraform fmt -recursive
	terraform-docs markdown . --output-file=README.md

help:
	@echo
	@echo "make ACTION env=ENVIRONMNET"
	@echo
	@echo "ACTION				COMMENT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Note that workspaces are created the first time you run \`plan\`."

init: ## Initialize Terraform
	terraform init
	tflint --init

init-upgrade: ## Initializes Terraform and upgrade providers
	terraform init -upgrade
	tflint --init

lint: ## Lints Terraform. Runs automatically with validate
	terraform fmt -recursive
	tflint --enable-plugin=aws

plan: ## Runs terraform plan
	terraform fmt -recursive
	terraform plan -out=plan.tfplan
	$(MAKE) validate

sec: ## Verifies security of Terraform resources. Runs automatically with validate
	terraform fmt -recursive
	tfsec . --tfvars-file cloudflare.auto.tfvars

validate: ## Runs terraform validate, docs, lint, and sec. Runs automatically with plan and apply
	terraform fmt -recursive
	terraform validate
	$(MAKE) docs
	$(MAKE) lint
	$(MAKE) sec