ENV ?= dev
TFVARS = $(ENV).tfvars
BACKEND = $(ENV)_backend.config


init:
	terraform init -backend-config=$(BACKEND) -reconfigure


plan:
	terraform plan -out=tfplan -var-file=$(TFVARS)


apply:
	terraform apply tfplan


destroy:
	terraform destroy -var-file=$(TFVARS)