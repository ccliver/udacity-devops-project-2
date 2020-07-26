.DEFAULT_GOAL := help

REGION="us-east-1"
MY_IP=$(shell curl -s https://ifconfig.me)
STACK_NAME="udacity-project-2"
TERRAFORM_VERSION := 0.12.29
DOCKER_OPTIONS := -v ${PWD}:/work \
-w /work \
-it \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
-e MY_IP=${MY_IP}
AWS_CLI_OPTIONS := --stack-name ${STACK_NAME} \
--region ${REGION} \
--template-body file:///work/cloudformation/stack.yml

build_stack: ## Deploy all infrastructure with Cloudformation and deploy site
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation create-stack ${AWS_CLI_OPTIONS}

update_stack: ## Update deployed stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation update-stack ${AWS_CLI_OPTIONS}

show_stacks: ## Update deployed stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation describe-stacks --region ${REGION}

delete_stack: ## Update deployed stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation delete-stack \
	--stack-name ${STACK_NAME} --region ${REGION}

validate_template: ## Validate template syntax
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation validate-template \
	--region ${REGION} --template-body file:///work/cloudformation/stack.yml

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'