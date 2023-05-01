
init:
	terraform init
	terraform plan --var-file=conf/group.tfvars -out main.tfplan
	terraform apply main.tfplan

destroy:
	terraform init
	terraform plan -destroy --var-file=conf/group.tfvars -out main.destroy.tfplan
	terraform apply main.destroy.tfplan

clear: 
	rm -rf ./.terraform
	rm -f ./terraform.tfstate
	rm -f ./terraform.tfstate.backup
	rm -f ./.terraform.tfstate.lock.info
	rm -f ./.terraform.lock.hcl
	rm -f ./main.tfplan
	rm -f ./main.destroy.tfplan
