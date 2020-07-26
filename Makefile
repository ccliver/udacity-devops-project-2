.DEFAULT_GOAL := help

MY_IP=$(shell curl -s https://ifconfig.me)
TERRAFORM_VERSION := 0.12.29
DOCKER_OPTIONS := -v ${PWD}:/work \
-w /work \
-it \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
-e MY_IP=${MY_IP}
AWS_CLI_OPTIONS := ""

build_site: ## Deploy all infrastructure with Cloudformation and deploy site
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws s3 cloudformation create-stack ${AWS_CLI_OPTIONS}

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'