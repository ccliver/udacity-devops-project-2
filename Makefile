.DEFAULT_GOAL := help

REGION="us-east-1"
#MY_IP=$(shell curl -s https://ifconfig.me)
NETWORK_STACK_NAME="udacity-project-2-network"
INFRASTRUCTURE_STACK_NAME="udacity-project-2-infrastructure"
TERRAFORM_VERSION := 0.12.29
DOCKER_OPTIONS := -v ${PWD}:/work \
-w /work \
-it \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
-e MY_IP=${MY_IP}
AWS_CLI_OPTIONS := --region ${REGION}
NETWORK_CLI_OPTIONS := ${AWS_CLI_OPTIONS} \
--stack-name ${NETWORK_STACK_NAME} \
--template-body file:///work/cloudformation/network.yml
INFRASTRUCTURE_CLI_OPTIONS := ${AWS_CLI_OPTIONS} \
--stack-name ${INFRASTRUCTURE_STACK_NAME} \
--capabilities CAPABILITY_IAM \
--template-body file:///work/cloudformation/infrastructure.yml \
--parameters file:///work/cloudformation/parameters.json
#--parameters ParameterKey=BastionAllowedIP,ParameterValue=${MY_IP}

generate_bastion_key: ## Create an SSH key to get on the bastion
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws ec2 create-key-pair --region ${REGION} --key-name bastion-key | jq -r .KeyMaterial > id_rsa
	@chmod 400 id_rsa

build_network: ## Deploy all VPC stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation create-stack ${NETWORK_CLI_OPTIONS}

build_infrastructure: ## Deploy app resources: ALB, ASG, etc
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation create-stack ${INFRASTRUCTURE_CLI_OPTIONS}

update_network_stack: ## Update network stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation update-stack ${NETWORK_CLI_OPTIONS}

update_infrastructure_stack: ## Update infrastructure stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation update-stack ${INFRASTRUCTURE_CLI_OPTIONS}

show_stacks: ## Show deployed stacks
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation describe-stacks --region ${REGION}

delete_network: ## Delete the network stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation delete-stack \
	--stack-name ${NETWORK_STACK_NAME} --region ${REGION}

delete_infrastructure: ## Delete the infrastructure stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation delete-stack \
	--stack-name ${INFRASTRUCTURE_STACK_NAME} --region ${REGION}

validate_templates: ## Validate template syntax
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation validate-template \
	--region ${REGION} --template-body file:///work/cloudformation/network.yml
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation validate-template \
	--region ${REGION} --template-body file:///work/cloudformation/infrastructure.yml

ssh_bastion: ## SSH to the bastion host
	@ssh -i id_rsa ec2-user@$(shell aws cloudformation describe-stacks --stack-name ${INFRASTRUCTURE_STACK_NAME} | jq -r .Stacks[0].Outputs[1].OutputValue)

lb_url: ## Output the load balancer url
	@echo "http://$(shell aws cloudformation describe-stacks --stack-name ${INFRASTRUCTURE_STACK_NAME} | jq -r .Stacks[0].Outputs[0].OutputValue)"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'