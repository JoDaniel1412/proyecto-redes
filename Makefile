
init:
	terraform init
	terraform plan --var-file=conf/group.tfvars -out main.tfplan
	terraform apply main.tfplan

destroy:
	terraform init
	terraform plan -destroy --var-file=conf/group.tfvars -out main.destroy.tfplan
	terraform apply main.destroy.tfplan

clear: 
	rm ./terraform.tfstate
	rm ./terraform.lock.hcl
	rm ./main.tfplan
