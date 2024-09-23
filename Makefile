.PHONY: init plan apply output down up

init-upgrade:
	terraform -chdir=./terraform init -upgrade

init:
	terraform -chdir=./terraform init

plan:
	terraform -chdir=./terraform plan

apply:
	terraform -chdir=./terraform apply

output:
	terraform -chdir=./terraform output

down:
	terraform -chdir=./terraform destroy -auto-approve